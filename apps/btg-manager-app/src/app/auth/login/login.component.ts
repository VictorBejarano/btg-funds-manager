import { Component, effect, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthStore } from '../../state/auth.store';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
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
