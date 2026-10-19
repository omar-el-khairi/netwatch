import { useEffect } from 'react';
import { io } from 'socket.io-client';
import { API_URL } from '../api';

/** Hook global : écoute Socket.IO et dispatch des CustomEvents pour les pages. */
export function useSocket() {
  useEffect(() => {
    const socket = io(API_URL, { transports: ['websocket', 'polling'] });

    socket.on('alert:new', (alert) => {
      window.dispatchEvent(new CustomEvent('nw:alert', { detail: alert }));
    });
    socket.on('server:update', (server) => {
      window.dispatchEvent(new CustomEvent('nw:server', { detail: server }));
    });
    socket.on('metric:new', (payload) => {
      window.dispatchEvent(new CustomEvent('nw:metric', { detail: payload }));
    });

    return () => socket.disconnect();
  }, []);
}
