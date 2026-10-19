import { useCallback, useEffect, useState } from 'react';
import { api, API_URL, getToken } from '../api';
import { formatDate } from '../components/StatusBadge';

export default function AlertsPage() {
  const [alerts, setAlerts] = useState([]);
  const [filter, setFilter] = useState('all');
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    try {
      const q =
        filter === 'open'
          ? '?acknowledged=false'
          : filter === 'critical'
            ? '?severity=critical'
            : '';
      const data = await api(`/api/alerts${q}`);
      setAlerts(data);
      setError('');
    } catch (err) {
      setError(err.message);
    }
  }, [filter]);

  useEffect(() => {
    load();
    const onAlert = () => load();
    window.addEventListener('nw:alert', onAlert);
    return () => window.removeEventListener('nw:alert', onAlert);
  }, [load]);

  async function acknowledge(id) {
    await api(`/api/alerts/${id}/acknowledge`, { method: 'POST' });
    load();
  }

  async function exportCsv() {
    const token = getToken();
    const res = await fetch(`${API_URL}/api/alerts/export?format=csv`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) {
      setError('Export CSV impossible');
      return;
    }
    const blob = await res.blob();
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `netwatch-alerts-${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  function exportPdf() {
    const rows = alerts
      .map(
        (a) => `
      <tr>
        <td>${formatDate(a.createdAt)}</td>
        <td>${a.severity}</td>
        <td>${a.type}</td>
        <td>${a.server?.name || ''}</td>
        <td>${(a.message || '').replace(/</g, '&lt;')}</td>
      </tr>`
      )
      .join('');
    const html = `<!DOCTYPE html><html><head><meta charset="utf-8"/><title>NetWatch Alertes</title>
      <style>
        body{font-family:Segoe UI,Arial,sans-serif;padding:24px;color:#111}
        h1{margin:0 0 8px} p{color:#555}
        table{width:100%;border-collapse:collapse;margin-top:16px;font-size:12px}
        th,td{border:1px solid #ddd;padding:8px;text-align:left;vertical-align:top}
        th{background:#f3f3f3}
      </style></head><body>
      <h1>NetWatch — Historique des alertes</h1>
      <p>Export du ${new Date().toLocaleString('fr-FR')} · ${alerts.length} ligne(s)</p>
      <table>
        <thead><tr><th>Date</th><th>Sévérité</th><th>Type</th><th>Serveur</th><th>Message</th></tr></thead>
        <tbody>${rows || '<tr><td colspan="5">Aucune alerte</td></tr>'}</tbody>
      </table>
      <script>window.onload=()=>window.print()</script>
      </body></html>`;
    const w = window.open('', '_blank');
    if (!w) {
      setError('Autorisez les popups pour export PDF');
      return;
    }
    w.document.write(html);
    w.document.close();
  }

  return (
    <div className="page">
      <header className="page-header">
        <div>
          <h1>Alertes</h1>
          <p>Historique et notifications temps réel</p>
        </div>
        <div className="filters">
          <button type="button" className={filter === 'all' ? 'active' : ''} onClick={() => setFilter('all')}>
            Toutes
          </button>
          <button type="button" className={filter === 'open' ? 'active' : ''} onClick={() => setFilter('open')}>
            Ouvertes
          </button>
          <button
            type="button"
            className={filter === 'critical' ? 'active' : ''}
            onClick={() => setFilter('critical')}
          >
            Critiques
          </button>
          <button type="button" onClick={exportCsv}>
            Export CSV
          </button>
          <button type="button" onClick={exportPdf}>
            Export PDF
          </button>
        </div>
      </header>

      {error && <p className="error">{error}</p>}

      <ul className="alert-list dense">
        {alerts.map((a) => (
          <li key={a.id} className={`alert-item sev-${a.severity}`}>
            <div>
              <strong>
                {a.type} — {a.server?.name || 'Serveur'}
              </strong>
              <p>{a.message}</p>
              <small className="muted">{formatDate(a.createdAt)}</small>
            </div>
            {!a.acknowledged ? (
              <button type="button" onClick={() => acknowledge(a.id)}>
                Acquitter
              </button>
            ) : (
              <span className="muted">Acquittée</span>
            )}
          </li>
        ))}
        {alerts.length === 0 && <li className="muted">Aucune alerte</li>}
      </ul>
    </div>
  );
}
