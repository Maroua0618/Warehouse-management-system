import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutGrid, Users, Warehouse, Package, 
  ShieldAlert, ClipboardList, Box 
} from 'lucide-react';

const navItems = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutGrid },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Warehouses', href: '/warehouses', icon: Warehouse },
  { name: 'Products', href: '/products', icon: Package },
  { name: 'Overrides', href: '/overrides', icon: ShieldAlert },
  { name: 'Audit Logs', href: '/audit-logs', icon: ClipboardList },
  { name: 'Inventory', href: '/inventory', icon: Box },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 min-h-screen bg-[#08677A] flex flex-col text-white">
      {/* Brand Header */}
      <div className="p-6 mb-4">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-white/10 rounded-lg flex items-center justify-center">
            <Warehouse size={20} className="text-white" />
          </div>
          <div>
            <h1 className="font-space-grotesk font-bold text-lg leading-tight">MobAI BMS</h1>
            <p className="font-inter text-[10px] tracking-widest text-white/60 uppercase">Enterprise Admin</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-4 space-y-2">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 font-inter text-sm ${
                isActive 
                  ? 'bg-white/10 text-white shadow-sm' 
                  : 'text-white/70 hover:bg-white/5 hover:text-white'
              }`}
            >
              <item.icon size={18} strokeWidth={isActive ? 2.5 : 2} />
              <span className={isActive ? "font-semibold" : "font-medium"}>{item.name}</span>
            </Link>
          );
        })}
      </nav>

      {/* Footer Logo */}
      <div className="p-6">
        <div className="flex items-center gap-2 opacity-90">
            <img src="/logo.png" alt="BMS Electric Logo" className="h-10 w-auto" />
            <div className="flex items-baseline gap-1">
            <span className="font-space-grotesk font-bold text-2xl italic tracking-tighter text-[#F9A825]">BMS</span>
            <span className="font-inter text-[8px] font-bold uppercase tracking-widest text-white">Electric</span>
            </div>
        </div>
      </div>
    </aside>
  );
}