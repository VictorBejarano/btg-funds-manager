import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { map, take } from 'rxjs/operators';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const router = inject(Router);
  const authService = inject(AuthService);
  
  // Wait for initial auth state using the observable
  return authService.user$.pipe(
    take(1),
    map(user => {
      if (user) {
        return true;
      }
      return router.createUrlTree(['/login']);
    })
  );
};

export const unauthGuard: CanActivateFn = () => {
  const router = inject(Router);
  const authService = inject(AuthService);
  
  return authService.user$.pipe(
    take(1),
    map(user => {
      if (!user) {
        return true;
      }
      return router.createUrlTree(['/']);
    })
  );
};
