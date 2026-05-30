import { useState } from 'react';
import { EnvelopeIcon, PhoneIcon, WrenchScrewdriverIcon, Bars3Icon, XMarkIcon } from '@heroicons/react/24/outline';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  const navLinks = [
    { name: 'Beranda', path: '#home' },
    { name: 'Tentang Kami', path: '#tentang' },
    { name: 'Layanan', path: '#layanan' },
    { name: 'Testimoni', path: '#testimoni' },
    { name: 'Lokasi Tukang', path: '#maps' },
    { name: 'Call Center', path: '#call-center' },
  ];

  return (
    <header className="w-full font-sans sticky top-0 z-50 shadow-md">
      {/* Top Bar - Hidden on mobile for space */}
      <div className="hidden md:block bg-white text-gray-800 border-b border-gray-100">
        <div className="kangmas-container">
          <div className="flex justify-between items-center h-20">
            {/* Logo */}
            <div className="flex items-center gap-2">
              <WrenchScrewdriverIcon className="h-8 w-8 text-primary" />
              <span className="text-3xl font-bold tracking-tight">KANGMAS</span>
            </div>

            {/* Contact Info */}
            <div className="flex items-center gap-8">
              <div className="flex items-center gap-3">
                <div className="bg-primary/20 p-2 rounded-full border border-primary/30">
                  <EnvelopeIcon className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-gray-500 font-medium">Email Kami</p>
                  <p className="text-sm font-semibold">tukangcallcenter@gmail.com</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="bg-primary/20 p-2 rounded-full border border-primary/30">
                  <PhoneIcon className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-gray-500 font-medium">Kontak Kami</p>
                  <p className="text-sm font-semibold">+62 130-0000-000</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Navigation Bar */}
      <div className="bg-primary">
        <div className="kangmas-container">
          <div className="flex justify-between items-center h-14 md:h-14 lg:h-14">

            {/* Mobile Logo (Visible only on mobile) */}
            <div className="flex md:hidden items-center gap-2">
              <WrenchScrewdriverIcon className="h-6 w-6 text-gray-900" />
              <span className="text-xl font-bold tracking-tight text-gray-900">KANGMAS</span>
            </div>

            {/* Desktop Nav */}
            <nav className="hidden md:flex flex-1 space-x-2">
              {navLinks.map((link) => (
                <a
                  key={link.name}
                  href={link.path}
                  className="px-4 py-4 text-sm font-bold text-gray-800 hover:text-black hover:bg-black/5 transition-colors border-b-4 border-transparent hover:border-dark"
                >
                  {link.name}
                </a>
              ))}
            </nav>

            {/* Desktop Action Buttons */}
            <div className="hidden md:flex gap-2">
              <a href="/admin/login" className="bg-white text-gray-900 px-4 py-2 text-sm font-bold border border-gray-900 hover:bg-gray-100 transition-colors rounded">
                Login Admin
              </a>
              <a href="/register-tukang" className="bg-dark text-white px-4 py-2 text-sm font-bold hover:bg-dark-lighter transition-colors rounded flex items-center justify-center">
                Daftar Tukang
              </a>
            </div>

            {/* Mobile Menu Toggle */}
            <div className="md:hidden flex items-center">
              <button onClick={() => setIsOpen(!isOpen)} className="text-gray-900 hover:text-black p-2">
                {isOpen ? <XMarkIcon className="h-6 w-6" /> : <Bars3Icon className="h-6 w-6" />}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {isOpen && (
        <div className="md:hidden bg-primary border-t border-yellow-500 absolute w-full shadow-lg">
          <div className="kangmas-container py-4 flex flex-col space-y-2">
            {navLinks.map((link) => (
              <a
                key={link.name}
                href={link.path}
                onClick={() => setIsOpen(false)}
                className="px-4 py-3 text-sm font-bold text-gray-900 border-b border-black/10 hover:bg-white/20 rounded"
              >
                {link.name}
              </a>
            ))}
            <div className="flex flex-col gap-2 pt-4">
              <a href="/admin/login" className="bg-white text-center text-gray-900 px-4 py-3 text-sm font-bold rounded shadow-sm">
                Login Admin
              </a>
              <a href="/register-tukang" className="bg-dark text-center text-white px-4 py-3 text-sm font-bold rounded shadow-sm">
                Daftar Tukang Web
              </a>
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
