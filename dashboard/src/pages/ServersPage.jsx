import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api';
import { StatusBadge, formatDate } from '../components/StatusBadge';

export default function ServersPage() {
  const [servers, setServers] = useState([]);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    name: '',
    hostname: '',
    ipAddress: '',
    osType: 'linux',
  });
  const [createdKey, setCreatedKey] = useState(null);

  const load = useCallback(async () => {
    try {
      const data = await api('/api/servers');
      setServers(data);
      setError('');
    } catch (err) {
      setError(err.message);
    }
  }, []);

  useEffect(() => {
    load();
    const onServer = () => load();
    window.addEventListener('nw:server', onServer);
    window.addEventListener('nw:alert', onServer);
    return () => {
      window.removeEventListener('nw:server', onServer);
      window.removeEventListener('nw:alert', onServer);
    };
  }, [load]);

  async function createServer(e) {
    e.preventDefault();
    try {
      const server = await api('/api/servers', {
        method: 'POST',
        body: JSON.stringify(form),
      });
      setCreatedKey(server.apiKey);
      setShowForm(false);
      setForm({ name: '', hostname: '', ipAddress: '', osType: 'linux' });
      await load();
    } catch (err) {
      setError(err.message);
    }
  }

  const counts = servers.reduce(
    (acc, s) => {
      acc[s.status] = (acc[s.status] || 0) + 1;
      acc.total += 1;
      return acc;
    },
    { total: 0 }
  );

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>Parc informatique</h1>
          <p>État temps réel des serveurs surveillés</p>
        </div>
        <button type="button" onClick={() => setShowForm((v) => !v)}>
          {showForm ? 'Fermer' : 'Ajouter un serveur'}
        </button>
      </header>

      <div className="stat-row">
        <div className="stat">
          <span>Total</span>
          <strong>{counts.total || 0}</strong>
        </div>
        <div className="stat ok">
          <span>Online</span>
          <strong>{counts.online || 0}</strong>
        </div>
        <div className="stat warn">
          <span>Warning</span>
          <strong>{counts.warning || 0}</strong>
        </div>
        <div className="stat crit">
          <span>Critique / Down</span>
          <strong>{(counts.critical || 0) + (counts.down || 0)}</strong>
        </div>
      </div>

      {error && <p className="error">{error}</p>}
      {createdKey && (
        <div className="notice">
          <strong>Clé agent générée</strong>
          <code>{createdKey}</code>
          <p>À coller dans <code>agents/config.json</code> → apiKey</p>
          <button type="button" className="linkish" onClick={() => setCreatedKey(null)}>
            Fermer
          </button>
        </div>
      )}

      {showForm && (
        <form className="panel form-grid" onSubmit={createServer}>
          <label>
            Nom
            <input
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              required
            />
          </label>
          <label>
            Hostname
            <input
              value={form.hostname}
              onChange={(e) => setForm({ ...form, hostname: e.target.value })}
              required
            />
          </label>
          <label>
            Adresse IP
            <input
              value={form.ipAddress}
              onChange={(e) => setForm({ ...form, ipAddress: e.target.value })}
              required
            />
          </label>
          <label>
            OS
            <select
              value={form.osType}
              onChange={(e) => setForm({ ...form, osType: e.target.value })}
            >
              <option value="linux">Linux</option>
              <option value="windows">Windows</option>
            </select>
          </label>
          <button type="submit">Enregistrer</button>
        </form>
      )}

      <div className="server-grid">
        {servers.map((s) => (
          <Link to={`/servers/${s.id}`} key={s.id} className={`server-card status-${s.status}`}>
            <div className="server-card-top">
              <h2>{s.name}</h2>
              <StatusBadge status={s.status} />
            </div>
            <p className="muted">
              {s.hostname} · {s.ipAddress} · {s.osType}
            </p>
            {s.latestMetric ? (
              <div className="metric-pills">
                <span>CPU {s.latestMetric.cpuPercent.toFixed(0)}%</span>
                <span>RAM {s.latestMetric.ramPercent.toFixed(0)}%</span>
                <span>DISQUE {s.latestMetric.diskPercent.toFixed(0)}%</span>
              </div>
            ) : (
              <p className="muted">En attente de la première métrique…</p>
            )}
            <small className="muted">Vu : {formatDate(s.lastSeenAt)}</small>
          </Link>
        ))}
        {servers.length === 0 && (
          <p className="muted">Aucun serveur. Ajoutez-en un ou lancez le seed + agent.</p>
        )}
      </div>
    </div>
  );
}
