import { useState, useEffect, useCallback } from 'react';
import { supabase } from './lib/supabase';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend
} from 'recharts';
import {
  Users,
  UserMinus,
  Utensils,
  Leaf,
  TrendingDown,
  RefreshCw,
  AlertCircle,
  IndianRupee,
  Calendar,
  BarChart3,
  PieChart as PieChartIcon,
  Activity
} from 'lucide-react';

const MEAL_COST = parseInt(import.meta.env.VITE_MEAL_COST || '110');

const COLORS = {
  blue: '#3b82f6',
  green: '#10b981',
  red: '#ef4444',
  purple: '#8b5cf6',
  orange: '#f59e0b',
  cyan: '#06b6d4',
  pink: '#ec4899'
};

const CustomTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    return (
      <div className="custom-tooltip">
        <p className="label">{label}</p>
        {payload.map((entry, index) => (
          <p key={index} className="value" style={{ color: entry.color }}>
            {entry.name}: {entry.value}
          </p>
        ))}
      </div>
    );
  }
  return null;
};

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchData = useCallback(async () => {
    try {
      setRefreshing(true);

      // Get total students
      const { data: studentsData, error: studentsError } = await supabase
        .from('students')
        .select('student_id', { count: 'exact' });

      if (studentsError) throw studentsError;
      const totalStudents = studentsData?.length || 0;

      // Get students on leave today
      const today = new Date().toISOString().split('T')[0];
      const { data: leaveData, error: leaveError } = await supabase
        .from('leave_requests')
        .select('student_id')
        .lte('start_date', today)
        .gte('end_date', today);

      if (leaveError) throw leaveError;
      const uniqueOnLeave = [...new Set(leaveData?.map(l => l.student_id) || [])].length;

      // Get leave analytics (last 30 days)
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      
      const { data: allLeaves, error: allLeavesError } = await supabase
        .from('leave_requests')
        .select('student_id, start_date, end_date')
        .gte('end_date', thirtyDaysAgo.toISOString().split('T')[0]);

      if (allLeavesError) throw allLeavesError;

      // Process leave data for chart
      const leaveByDate = {};
      allLeaves?.forEach(leave => {
        const start = new Date(leave.start_date);
        const end = new Date(leave.end_date);
        for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
          const dateStr = d.toISOString().split('T')[0];
          if (!leaveByDate[dateStr]) leaveByDate[dateStr] = new Set();
          leaveByDate[dateStr].add(leave.student_id);
        }
      });

      const leaveAnalytics = Object.entries(leaveByDate)
        .map(([date, students]) => ({
          date: new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
          fullDate: date,
          count: students.size
        }))
        .sort((a, b) => new Date(a.fullDate) - new Date(b.fullDate))
        .slice(-14); // Last 14 days

      const mealsServed = totalStudents - uniqueOnLeave;
      const mealsSaved = uniqueOnLeave;
      const costSaved = mealsSaved * MEAL_COST;

      setData({
        totalStudents,
        onLeave: uniqueOnLeave,
        mealsServed,
        mealsSaved,
        costSaved,
        leaveAnalytics
      });

      setLastUpdated(new Date());
      setError(null);
    } catch (err) {
      console.error('Error fetching data:', err);
      setError(err.message || 'Failed to fetch data from Supabase');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    fetchData();

    // Auto-refresh every 30 seconds
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [fetchData]);

  if (loading && !data) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p className="loading-text">Loading dashboard data...</p>
      </div>
    );
  }

  if (error && !data) {
    return (
      <div className="error-container">
        <div className="error-icon">
          <AlertCircle size={32} />
        </div>
        <h2 className="error-title">Failed to Load Data</h2>
        <p className="error-message">{error}</p>
        <button className="retry-btn" onClick={fetchData}>
          Try Again
        </button>
      </div>
    );
  }

  const {
    totalStudents,
    onLeave,
    mealsServed,
    mealsSaved,
    costSaved,
    leaveAnalytics
  } = data;

  // Chart data
  const attendanceData = [
    { name: 'Total Students', value: totalStudents, fill: COLORS.blue },
    { name: 'On Leave', value: onLeave, fill: COLORS.red },
    { name: 'Present', value: mealsServed, fill: COLORS.green }
  ];

  const mealComparisonData = [
    { name: 'Expected', meals: totalStudents },
    { name: 'Served', meals: mealsServed },
    { name: 'Saved', meals: mealsSaved }
  ];

  const pieData = [
    { name: 'Meals Served', value: mealsServed },
    { name: 'Meals Saved', value: mealsSaved }
  ];

  const efficiencyRate = totalStudents > 0 
    ? ((mealsSaved / totalStudents) * 100).toFixed(1) 
    : 0;

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="header">
        <div className="header-left">
          <div className="logo">🍽️</div>
          <div className="header-title">
            <h1>Mess Analytics</h1>
            <p>Real-time hostel meal tracking dashboard</p>
          </div>
        </div>
        <div className="header-right">
          <button 
            className="refresh-btn" 
            onClick={fetchData}
            disabled={refreshing}
          >
            <RefreshCw size={16} className={refreshing ? 'spinning' : ''} />
            {refreshing ? 'Refreshing...' : 'Refresh'}
          </button>
          {lastUpdated && (
            <span className="last-updated">
              Last updated: {lastUpdated.toLocaleTimeString()}
            </span>
          )}
        </div>
      </header>

      {/* Stats Cards */}
      <div className="stats-grid">
        <div className="stat-card blue">
          <div className="stat-header">
            <div className="stat-icon">
              <Users size={24} />
            </div>
            <span className="stat-badge">Total</span>
          </div>
          <div className="stat-value">{totalStudents.toLocaleString()}</div>
          <div className="stat-label">Total Students</div>
        </div>

        <div className="stat-card red">
          <div className="stat-header">
            <div className="stat-icon">
              <UserMinus size={24} />
            </div>
            <span className="stat-badge">Today</span>
          </div>
          <div className="stat-value">{onLeave.toLocaleString()}</div>
          <div className="stat-label">On Leave</div>
        </div>

        <div className="stat-card green">
          <div className="stat-header">
            <div className="stat-icon">
              <Utensils size={24} />
            </div>
            <span className="stat-badge">Active</span>
          </div>
          <div className="stat-value">{mealsServed.toLocaleString()}</div>
          <div className="stat-label">Meals to Serve</div>
        </div>

        <div className="stat-card purple">
          <div className="stat-header">
            <div className="stat-icon">
              <Leaf size={24} />
            </div>
            <span className="stat-badge">{efficiencyRate}%</span>
          </div>
          <div className="stat-value">{mealsSaved.toLocaleString()}</div>
          <div className="stat-label">Meals Saved</div>
        </div>
      </div>

      {/* Savings Banner */}
      <div className="savings-banner">
        <div className="savings-content">
          <h2>
            <IndianRupee size={18} />
            Today's Cost Savings
          </h2>
          <div className="savings-amount">₹{costSaved.toLocaleString()}</div>
        </div>
        <div className="savings-details">
          <div className="savings-detail">
            <div className="savings-detail-value">{mealsSaved}</div>
            <div className="savings-detail-label">Meals Avoided</div>
          </div>
          <div className="savings-detail">
            <div className="savings-detail-value">₹{MEAL_COST}</div>
            <div className="savings-detail-label">Per Meal Cost</div>
          </div>
          <div className="savings-detail">
            <div className="savings-detail-value">{efficiencyRate}%</div>
            <div className="savings-detail-label">Efficiency</div>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="charts-grid">
        {/* Leave Trend Chart */}
        <div className="chart-card full-width">
          <div className="chart-header">
            <h3>
              <Activity size={20} />
              Leave Trend (Last 14 Days)
            </h3>
            <span className="chart-badge">
              <Calendar size={12} /> Daily
            </span>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={leaveAnalytics}>
              <defs>
                <linearGradient id="colorLeave" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={COLORS.red} stopOpacity={0.3}/>
                  <stop offset="95%" stopColor={COLORS.red} stopOpacity={0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis 
                dataKey="date" 
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <YAxis 
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Area
                type="monotone"
                dataKey="count"
                name="Students on Leave"
                stroke={COLORS.red}
                strokeWidth={2}
                fillOpacity={1}
                fill="url(#colorLeave)"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Attendance Overview */}
        <div className="chart-card">
          <div className="chart-header">
            <h3>
              <BarChart3 size={20} />
              Attendance Overview
            </h3>
            <span className="chart-badge">Today</span>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={attendanceData} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis 
                type="number" 
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <YAxis 
                dataKey="name" 
                type="category" 
                width={100}
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar 
                dataKey="value" 
                name="Count"
                radius={[0, 8, 8, 0]}
              >
                {attendanceData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Meals Distribution Pie */}
        <div className="chart-card">
          <div className="chart-header">
            <h3>
              <PieChartIcon size={20} />
              Meals Distribution
            </h3>
            <span className="chart-badge">Ratio</span>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie
                data={pieData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={100}
                paddingAngle={5}
                dataKey="value"
              >
                <Cell fill={COLORS.green} />
                <Cell fill={COLORS.purple} />
              </Pie>
              <Tooltip content={<CustomTooltip />} />
              <Legend 
                verticalAlign="bottom"
                iconType="circle"
                formatter={(value) => <span style={{ color: '#94a3b8' }}>{value}</span>}
              />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Meal Comparison */}
        <div className="chart-card">
          <div className="chart-header">
            <h3>
              <TrendingDown size={20} />
              Wastage Reduction
            </h3>
            <span className="chart-badge">Comparison</span>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={mealComparisonData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis 
                dataKey="name" 
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <YAxis 
                stroke="#64748b"
                tick={{ fill: '#94a3b8', fontSize: 12 }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar 
                dataKey="meals" 
                name="Meals"
                radius={[8, 8, 0, 0]}
              >
                <Cell fill={COLORS.blue} />
                <Cell fill={COLORS.green} />
                <Cell fill={COLORS.purple} />
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}

export default App;
