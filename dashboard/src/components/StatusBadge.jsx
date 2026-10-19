export function statusLabel(status) {
  const map = {
    online: 'Opérationnel',
    warning: 'Avertissement',
    critical: 'Critique',
    down: 'Injoignable',
    pending: 'En attente',
  };
  return map[status] || status;
}

export function StatusBadge({ status }) {
  return <span className={`badge badge-${status}`}>{statusLabel(status)}</span>;
}

export function formatUptime(seconds) {
  if (!seconds && seconds !== 0) return '—';
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (d > 0) return `${d}j ${h}h`;
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m`;
}

export function formatDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleString('fr-FR');
}
