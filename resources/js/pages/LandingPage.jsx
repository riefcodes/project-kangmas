import React from 'react';
import HomeSection from '../components/sections/HomeSection';
import TentangSection from '../components/sections/TentangSection';
import LayananSection from '../components/sections/LayananSection';
import TestimoniSection from '../components/sections/TestimoniSection';
import MapsSection from '../components/sections/MapsSection';
import DownloadAppSection from '../components/sections/DownloadAppSection';

export default function LandingPage() {
  return (
    <div>
      <HomeSection />
      <TentangSection />
      <LayananSection />
      <TestimoniSection />
      <MapsSection />
      <DownloadAppSection />
    </div>
  );
}
