import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BackendService, Usuario } from './services/backend.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  
  usuarios: Usuario[] = [];
  cargando: boolean = true;
  error: string | null = null;

  constructor(private backendService: BackendService) { }

  ngOnInit(): void {
    this.cargarUsuarios();
  }

  cargarUsuarios(): void {
    this.cargando = true;
    this.error = null;

    this.backendService.obtenerUsuarios().subscribe({
      next: (data: Usuario[]) => {
        this.usuarios = data;
        this.cargando = false;
        console.log('Usuarios cargados:', this.usuarios);
      },
      error: (err) => {
        console.error('Error al cargar usuarios:', err);
        this.error = `Error al conectar con el backend: ${err.message}`;
        this.cargando = false;
      }
    });
  }

  recargar(): void {
    this.cargarUsuarios();
  }
}
