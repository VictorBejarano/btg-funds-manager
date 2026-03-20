import { Component, effect, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthStore } from '../../state/auth.store';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  template: `
    <div class="login-container">
      <div class="login-card">
        <div class="logo-area">
          <div class="icon-placeholder">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
            </svg>
          </div>
          <h2>BTG Manager</h2>
          <p>Sign in to manage your funds</p>
        </div>

        <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="email">Email</label>
            <input 
              type="email" 
              id="email" 
              formControlName="email" 
              placeholder="admin@btg.com"
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input 
              type="password" 
              id="password" 
              formControlName="password" 
              placeholder="••••••••"
            />
          </div>

          <div class="error-msg" *ngIf="authStore.error()">
            {{ authStore.error() }}
          </div>

          <button 
            type="submit" 
            [disabled]="loginForm.invalid || authStore.loading()"
          >
            <span *ngIf="!authStore.loading()">Sign In</span>
            <span *ngIf="authStore.loading()" class="loader"></span>
          </button>
          
          <!-- Mocking a register behavior since there wasn't an explicit register page in earlier prompt but it was in plan -->
          <div class="register-link">
            Don't have an account? 
            <a href="javascript:void(0)" (click)="registerMockAccount()">Create test account</a>
          </div>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background-color: #0b0f19;
      background-image: radial-gradient(circle at 50% -20%, #1a233a 0%, #0b0f19 50%);
      font-family: 'Inter', system-ui, sans-serif;
      color: #e2e8f0;
    }

    .login-card {
      background: rgba(15, 23, 42, 0.7);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 20px;
      padding: 3rem;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    }

    .logo-area {
      text-align: center;
      margin-bottom: 2.5rem;
    }

    .icon-placeholder {
      width: 64px;
      height: 64px;
      background: linear-gradient(135deg, #38bdf8, #3b82f6);
      border-radius: 16px;
      margin: 0 auto 1.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 10px 25px -5px rgba(59, 130, 246, 0.5);

      svg {
        width: 32px;
        height: 32px;
        color: white;
      }
    }

    h2 {
      font-size: 1.75rem;
      font-weight: 700;
      color: #f8fafc;
      margin: 0 0 0.5rem;
      letter-spacing: -0.025em;
    }

    p {
      color: #94a3b8;
      font-size: 0.95rem;
      margin: 0;
    }

    .form-group {
      margin-bottom: 1.5rem;

      label {
        display: block;
        font-size: 0.875rem;
        font-weight: 500;
        color: #cbd5e1;
        margin-bottom: 0.5rem;
      }

      input {
        width: 100%;
        background: rgba(15, 23, 42, 0.6);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        padding: 0.875rem 1rem;
        color: #f8fafc;
        font-size: 1rem;
        transition: all 0.2s;
        box-sizing: border-box;

        &:focus {
          outline: none;
          border-color: #3b82f6;
          box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.25);
        }
        
        &::placeholder {
          color: #475569;
        }
      }
    }

    button {
      width: 100%;
      background: linear-gradient(135deg, #38bdf8, #3b82f6);
      color: white;
      border: none;
      border-radius: 12px;
      padding: 0.875rem;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      margin-top: 1rem;
      position: relative;
      height: 52px;
      display: flex;
      justify-content: center;
      align-items: center;

      &:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 10px 20px -5px rgba(59, 130, 246, 0.4);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    .error-msg {
      color: #ef4444;
      font-size: 0.875rem;
      margin-bottom: 1rem;
      text-align: center;
      background: rgba(239, 68, 68, 0.1);
      padding: 0.75rem;
      border-radius: 8px;
    }

    .register-link {
      text-align: center;
      margin-top: 1.5rem;
      font-size: 0.875rem;
      color: #94a3b8;

      a {
        color: #38bdf8;
        text-decoration: none;
        font-weight: 500;
        transition: color 0.2s;

        &:hover {
          color: #7dd3fc;
        }
      }
    }

    .loader {
      border: 3px solid rgba(255, 255, 255, 0.3);
      width: 20px;
      height: 20px;
      border-radius: 50%;
      border-left-color: #fff;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `]
})
export class LoginComponent {
  authStore = inject(AuthStore);
  router = inject(Router);
  fb = inject(FormBuilder);

  loginForm = this.fb.nonNullable.group({
    email: ['alisson@gmail.com', [Validators.required, Validators.email]],
    password: ['alisson', [Validators.required, Validators.minLength(6)]]
  });

  constructor() {
    effect(() => {
      // If user successfully logs in, navigate to home
      if (this.authStore.uid()) {
        this.router.navigate(['/']);
      }
    });
  }

  async onSubmit() {
    if (this.loginForm.valid) {
      const { email, password } = this.loginForm.getRawValue();
      await this.authStore.login(email, password);
    }
  }

  async registerMockAccount() {
    if (this.loginForm.valid) {
      const { email, password } = this.loginForm.getRawValue();
      await this.authStore.register(email, password);
    } else {
      alert("Please fill email and a password >= 6 characters to register.");
    }
  }
}
