import { useEffect, useState } from 'react';
import { api } from '../api';

const TYPES = ['cpu', 'ram', 'disk'];

export default function ThresholdsPage() {
  const [defaults, setDefaults] = useState({});
  const [items, setItems] = useState([]);
  const [servers, setServers] = useState([]);
  const [form, setForm] = useState({
    metricType: 'cpu',
    warning: 70,
    critical: 90,
    serverId: '',
  });
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  async function load() {
    try {
      const [th, srv] = await Promise.all([api('/api/thresholds'), api('/api/servers')]);
      setDefaults(th.defaults || {});
      setItems(th.items || []);
      setServers(srv || []);
      setError('');
    } catch (err) {
      setError(err.message);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function save(e) {
    e.preventDefault();
    setMessage('');
    setError('');
    try {
      await api('/api/thresholds', {
        method: 'POST',
        body: JSON.stringify({
          metricType: form.metricType,
          warning: form.warning,
          critical: form.critical,
          serverId: form.serverId || null,
        }),
      });
      setMessage(
        form.serverId
          ? 'Seuil par serveur enregistré'
          : 'Seuil global enregistré'
      );
      load();
    } catch (err) {
      setError(err.message);
    }
  }

  function serverName(id) {
    if (!id) return 'Global';
    const s = servers.find((x) => x.id === id);
    return s ? s.name : id.slice(0, 8);
  }

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>Seuils d&apos;alerte</h1>
          <p>Globaux ou spécifiques à un serveur</p>
        </div>
      </header>

      <section className="panel">
        <h2>Défauts (code)</h2>
        <div className="metric-pills">
          {TYPES.map((t) => (
            <span key={t}>
              {t.toUpperCase()} W{defaults[t]?.warning ?? '—'} / C
              {defaults[t]?.critical ?? '—'}
            </span>
          ))}
        </div>
      </section>

      <form className="panel form-grid" onSubmit={save}>
        <label>
          Portée
          <select
            value={form.serverId}
            onChange={(e) => setForm({ ...form, serverId: e.target.value })}
          >
            <option value="">Global (tous les serveurs)</option>
            {servers.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name} ({s.hostname})
              </option>
            ))}
          </select>
        </label>
        <label>
          Métrique
          <select
            value={form.metricType}
            onChange={(e) => setForm({ ...form, metricType: e.target.value })}
          >
            {TYPES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </label>
        <label>
          Warning (%)
          <input
            type="number"
            min="1"
            max="100"
            value={form.warning}
            onChange={(e) => setForm({ ...form, warning: Number(e.target.value) })}
          />
        </label>
        <label>
          Critical (%)
          <input
            type="number"
            min="1"
            max="100"
            value={form.critical}
            onChange={(e) => setForm({ ...form, critical: Number(e.target.value) })}
          />
        </label>
        <button type="submit">Enregistrer</button>
      </form>

      {message && <p className="ok-msg">{message}</p>}
      {error && <p className="error">{error}</p>}

      <section className="panel">
        <h2>Seuils enregistrés</h2>
        <ul className="alert-list">
          {items.map((row) => (
            <li key={row.id}>
              <strong>{row.metricType.toUpperCase()}</strong> — warning {row.warning}% /
              critical {row.critical}% · <em>{serverName(row.serverId)}</em>
            </li>
          ))}
          {items.length === 0 && <li className="muted">Aucun seuil personnalisé</li>}
        </ul>
      </section>
    </div>
  );
}
