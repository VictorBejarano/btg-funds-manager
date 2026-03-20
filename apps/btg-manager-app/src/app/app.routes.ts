import { Route } from '@angular/router';
import { LoginComponent } from './auth/login/login.component';
import { authGuard, unauthGuard } from './guards/auth.guard';

export const appRoutes: Route[] = [
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [unauthGuard]
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./layout/main-layout/main-layout.component').then(m => m.MainLayoutComponent),
    children: [
      {
        path: '',
        redirectTo: 'funds',
        pathMatch: 'full'
      },
      {
        path: 'funds',
        loadComponent: () => import('./pages/funds/funds.component').then(m => m.FundsComponent)
      },
      {
        path: 'subscriptions',
        loadComponent: () => import('./pages/subscriptions/subscriptions.component').then(m => m.SubscriptionsComponent)
      },
      {
        path: 'profile',
        loadComponent: () => import('./pages/profile/profile.component').then(m => m.ProfileComponent)
      }
    ]
  },
  { path: '**', redirectTo: '' }
];
