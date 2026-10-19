import { Navigate, Route, Routes } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import ServersPage from './pages/ServersPage';
import ServerDetailPage from './pages/ServerDetailPage';
import AlertsPage from './pages/AlertsPage';
import ThresholdsPage from './pages/ThresholdsPage';

function PrivateRoute({ children }) {
  const { token, loading } = useAuth();
  if (loading) return <div className="center-screen">Chargement…</div>;
  if (!token) return <Navigate to="/login" replace />;
  return children;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/"
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route index element={<ServersPage />} />
        <Route path="servers/:id" element={<ServerDetailPage />} />
        <Route path="alerts" element={<AlertsPage />} />
        <Route path="thresholds" element={<ThresholdsPage />} />
      </Route>
    </Routes>
  );
}
