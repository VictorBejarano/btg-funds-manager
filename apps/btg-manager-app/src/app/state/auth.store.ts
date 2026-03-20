import { inject } from '@angular/core';
import { patchState, signalStore, withMethods, withState, withHooks } from '@ngrx/signals';
import { AuthService } from '../services/auth.service';

type AuthState = {
  uid: string | null;
  loading: boolean;
  error: string | null;
};

const initialState: AuthState = {
  uid: null,
  loading: false,
  error: null,
};

export const AuthStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods((store, authService = inject(AuthService)) => ({
    setLoading(loading: boolean) {
      patchState(store, { loading });
    },
    setError(error: string | null) {
      patchState(store, { error });
    },
    setUid(uid: string | null) {
      patchState(store, { uid, loading: false, error: null });
    },
    async login(email: string, password: string) {
      patchState(store, { loading: true, error: null });
      try {
        await authService.login(email, password);
      } catch (err: any) {
        patchState(store, { loading: false, error: err.message });
      }
    },
    async register(email: string, password: string) {
      patchState(store, { loading: true, error: null });
      try {
        await authService.register(email, password);
      } catch (err: any) {
        patchState(store, { loading: false, error: err.message });
      }
    },
    async logout() {
      patchState(store, { loading: true, error: null });
      try {
        await authService.logout();
      } catch (err: any) {
        patchState(store, { loading: false, error: err.message });
      }
    }
  })),
  withHooks({
    onInit(store, authService = inject(AuthService)) {
      // Listen to auth state changes directly
      authService.user$.subscribe((user) => {
        if (user) {
          store.setUid(user.uid);
        } else {
          store.setUid(null);
        }
      });
    }
  })
);
