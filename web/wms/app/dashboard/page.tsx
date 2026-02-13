import React from 'react';
import StatsCard from '@/components/dashboard/stats-card';
import { 
  Activity, 
  Users, 
  Package, 
  ShoppingCart, 
  CheckCircle2, 
  Clock 
} from 'lucide-react';

export default function DashboardPage() {
  // Mock data for the "Real-time Operations" table
  const tasks = [
    { id: 'TK-8821', employee: 'Bot-Alpha 09', operation: 'Picking', status: 'done' },
    { id: 'TK-8822', employee: 'Bot-Alpha 09', operation: 'receipt', status: 'waiting' },
    { id: 'TK-8823', employee: 'Bot-Alpha 09', operation: 'Picking', status: 'done' },
  ];

  return (
    <div className="space-y-8 p-8 bg-[#F1F4F9] min-h-screen">
      {/* Page Header */}
      <div>
        <h2 className="text-2xl font-space-grotesk font-bold text-[#1A1C1E]">
          Operational Overview
        </h2>
        <p className="text-slate-500 font-inter text-sm">
          Live warehouse metrics and AI pathfinding activity.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard 
          title="Active Chariots" 
          value="12 / 15" 
          icon={Activity} 
          trend={{ value: '12%', isPositive: true }} 
        />
        <StatsCard 
          title="Total SKUs" 
          value="1,284" 
          icon={Package} 
        />
        <StatsCard 
          title="Pending Tasks" 
          value="43" 
          icon={Clock} 
          trend={{ value: '5%', isPositive: false }} 
        />
        <StatsCard 
          title="Staff Online" 
          value="08" 
          icon={Users} 
        />
      </div>

      {/* Real-time Operations Table */}
      <div className="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-6 border-b border-gray-50 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <Activity className="text-[#08677A]" size={20} />
            <h3 className="font-space-grotesk font-bold text-[#08677A]">Real-time Operations</h3>
          </div>
          <span className="bg-slate-50 text-[10px] font-bold text-slate-400 px-3 py-1 rounded-md uppercase tracking-widest border border-slate-100">
            Live Monitor
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50/50">
                <th className="px-8 py-4 text-[11px] font-inter font-bold text-slate-400 uppercase tracking-widest">Task ID</th>
                <th className="px-8 py-4 text-[11px] font-inter font-bold text-slate-400 uppercase tracking-widest">Employee ID</th>
                <th className="px-8 py-4 text-[11px] font-inter font-bold text-slate-400 uppercase tracking-widest">Operation</th>
                <th className="px-8 py-4 text-[11px] font-inter font-bold text-slate-400 uppercase tracking-widest">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {tasks.map((task, idx) => (
                <tr key={idx} className="hover:bg-slate-50/30 transition-colors">
                  <td className="px-8 py-6 font-mono text-sm font-bold text-[#08677A]">
                    {task.id}
                  </td>
                  <td className="px-8 py-6 font-inter text-sm font-semibold text-[#1A1C1E]">
                    {task.employee}
                  </td>
                  <td className="px-8 py-6">
                    <span className="px-3 py-1 bg-blue-50 text-[#3B82F6] text-[10px] font-bold rounded-md lowercase">
                      {task.operation}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <div className={`inline-flex items-center gap-2 px-4 py-1.5 rounded-full border text-[11px] font-bold uppercase tracking-wider ${
                      task.status === 'done' 
                        ? 'bg-emerald-50 text-emerald-600 border-emerald-100' 
                        : 'bg-blue-50 text-blue-600 border-blue-100'
                    }`}>
                      <div className={`w-1.5 h-1.5 rounded-full ${
                        task.status === 'done' ? 'bg-emerald-500' : 'bg-blue-500'
                      }`} />
                      {task.status}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}