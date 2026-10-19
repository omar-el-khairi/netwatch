import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useSocket } from '../hooks/useSocket';

export default function Layout() {
  const { user, logout } = useAuth();
  useSocket();

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <span className="brand-mark" />
          <div>
            <strong>NetWatch</strong>
            <small>Supervision temps réel</small>
          </div>
        </div>
        <nav>
          <NavLink end to="/">
            Serveurs
          </NavLink>
          <NavLink to="/alerts">Alertes</NavLink>
          <NavLink to="/thresholds">Seuils</NavLink>
        </nav>
        <div className="sidebar-foot">
          <span>{user?.name || user?.email}</span>
          <button type="button" className="linkish" onClick={logout}>
            Déconnexion
          </button>
        </div>
      </aside>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
