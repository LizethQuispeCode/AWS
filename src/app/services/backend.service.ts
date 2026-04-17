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
  
  // Endpoint del backend - IP PRIVADA en EC2
  // En producción, cambiar por la IP privada real del backend EC2
  private backendUrl = 'http://10.0.0.10:8080/datos';

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
