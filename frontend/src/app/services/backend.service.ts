import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Usuario {
  id: number;
  nombre: string;
  correo: string;
}

@Injectable({
  providedIn: 'root'
})
export class BackendService {
  
  // Endpoint del backend - URL relativa (nginx proxy)
  // El frontend contacta a nginx en localhost, que redirige a backend privado
  private backendUrl = '/api/usuarios';

  constructor(private http: HttpClient) { }

  /**
   * Obtiene la lista de usuarios desde el backend
   * Endpoint: GET http://IP_PRIVADA_BACKEND:8080/datos
   */
  obtenerUsuarios(): Observable<Usuario[]> {
    return this.http.get<Usuario[]>(this.backendUrl);
  }

  /**
   * Obtiene un usuario específico por ID
   */
  obtenerUsuario(id: number): Observable<Usuario> {
    return this.http.get<Usuario>(`${this.backendUrl}/${id}`);
  }
}
