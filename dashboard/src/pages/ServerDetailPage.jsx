import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import {
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { api } from '../api';
import { StatusBadge, formatDate, formatUptime } from '../components/StatusBadge';

export default function ServerDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [server, setServer] = useState(null);
  const [metrics, setMetrics] = useState([]);
  const [error, setError] = useState('');
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    try {
      const [s, m] = await Promise.all([
        api(`/api/servers/${id}`),
        api(`/api/metrics/${id}?sinceMinutes=60&limit=200`),
      ]);
      setServer(s);
      setMetrics(m);
      setError('');
    } catch (err) {
      setError(err.message);
    }
  }, [id]);

  useEffect(() => {
    load();
    const onMetric = (e) => {
      if (e.detail?.serverId === id) load();
    };
    const onServer = (e) => {
      if (e.detail?.id === id) load();
    };
    window.addEventListener('nw:metric', onMetric);
    window.addEventListener('nw:server', onServer);
    return () => {
      window.removeEventListener('nw:metric', onMetric);
      window.removeEventListener('nw:server', onServer);
    };
  }, [id, load]);

  async function removeServer() {
    if (!window.confirm(`Supprimer le serveur « ${server?.name} » ?`)) return;
    setDeleting(true);
    try {
      await api(`/api/servers/${id}`, { method: 'DELETE' });
      navigate('/');
    } catch (err) {
      setError(err.message);
      setDeleting(false);
    }
  }

  if (error) return <p className="error">{error}</p>;
  if (!server) return <p className="muted">Chargement…</p>;

  const chartData = metrics.map((m) => ({
    time: new Date(m.collectedAt).toLocaleTimeString('fr-FR', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    }),
    cpu: m.cpuPercent,
    ram: m.ramPercent,
    disk: m.diskPercent,
  }));

  const lm = server.latestMetric;

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <Link to="/" className="back">
            ← Parc
          </Link>
          <h1>{server.name}</h1>
          <p>
            {server.hostname} · {server.ipAddress} · {server.osType}
          </p>
        </div>
        <StatusBadge status={server.status} />
      </header>

      <div className="page-header" style={{ marginTop: '-0.5rem', marginBottom: '1rem' }}>
        <button
          type="button"
          className="linkish"
          disabled={deleting}
          onClick={removeServer}
          style={{ color: 'var(--crit)', borderColor: 'rgba(255,93,108,0.4)' }}
        >
          {deleting ? 'Suppression…' : 'Supprimer ce serveur'}
        </button>
      </div>

      <div className="stat-row">
        <div className="stat">
          <span>CPU</span>
          <strong>{lm ? `${lm.cpuPercent.toFixed(1)}%` : '—'}</strong>
        </div>
        <div className="stat">
          <span>RAM</span>
          <strong>{lm ? `${lm.ramPercent.toFixed(1)}%` : '—'}</strong>
        </div>
        <div className="stat">
          <span>Disque</span>
          <strong>{lm ? `${lm.diskPercent.toFixed(1)}%` : '—'}</strong>
        </div>
        <div className="stat">
          <span>Uptime</span>
          <strong>{lm ? formatUptime(lm.uptimeSeconds) : '—'}</strong>
        </div>
      </div>

      <section className="panel">
        <h2>Métriques (60 min)</h2>
        {chartData.length === 0 ? (
          <p className="muted">Pas encore de données. Démarrez l&apos;agent.</p>
        ) : (
          <div className="chart-wrap">
            <ResponsiveContainer width="100%" height={320}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.08)" />
                <XAxis dataKey="time" stroke="#8b9bb4" tick={{ fontSize: 11 }} />
                <YAxis domain={[0, 100]} stroke="#8b9bb4" tick={{ fontSize: 11 }} />
                <Tooltip
                  contentStyle={{
                    background: '#0f1c2e',
                    border: '1px solid #243552',
                    borderRadius: 8,
                  }}
                />
                <Legend />
                <Line type="monotone" dataKey="cpu" name="CPU %" stroke="#3dd6c6" dot={false} strokeWidth={2} />
                <Line type="monotone" dataKey="ram" name="RAM %" stroke="#f0b429" dot={false} strokeWidth={2} />
                <Line type="monotone" dataKey="disk" name="Disque %" stroke="#7aa2ff" dot={false} strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}
      </section>

      <section className="panel">
        <h2>Clé agent</h2>
        <code className="api-key">{server.apiKey}</code>
        <p className="muted">Dernière vue : {formatDate(server.lastSeenAt)}</p>
      </section>

      <section className="panel">
        <h2>Alertes récentes</h2>
        <ul className="alert-list">
          {server.alerts?.length ? (
            server.alerts.map((a) => (
              <li key={a.id} className={`alert-item sev-${a.severity}`}>
                <div>
                  <strong>{a.type}</strong>
                  <p>{a.message}</p>
                </div>
                <small>{formatDate(a.createdAt)}</small>
              </li>
            ))
          ) : (
            <li className="muted">Aucune alerte</li>
          )}
        </ul>
      </section>
    </div>
  );
}
