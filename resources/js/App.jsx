import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/layout/Layout';
import LandingPage from './pages/LandingPage';
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminLogin from './pages/admin/AdminLogin';
import RegisterTukang from './pages/RegisterTukang';
import ProtectedRoute from './components/auth/ProtectedRoute';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<LandingPage />} />
        </Route>
        <Route path="/admin">
           <Route path="login" element={<AdminLogin />} />
           
           <Route element={<ProtectedRoute />}>
              <Route path="dashboard" element={<AdminDashboard />} />
           </Route>
        </Route>

        <Route path="/register-tukang" element={<RegisterTukang />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
