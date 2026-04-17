package com.proyecto.backend.controller;

import com.proyecto.backend.entity.Usuario;
import com.proyecto.backend.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    /**
     * Endpoint obligatorio: GET /datos
     * Retorna lista de usuarios desde la base de datos
     */
    @GetMapping("/datos")
    public ResponseEntity<List<Usuario>> obtenerDatos() {
        try {
            List<Usuario> usuarios = usuarioService.obtenerTodos();
            return ResponseEntity.ok(usuarios);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * GET /usuarios - Obtener todos los usuarios
     */
    @GetMapping("/usuarios")
    public ResponseEntity<List<Usuario>> obtenerUsuarios() {
        List<Usuario> usuarios = usuarioService.obtenerTodos();
        return ResponseEntity.ok(usuarios);
    }

    /**
     * GET /usuarios/{id} - Obtener usuario por ID
     */
    @GetMapping("/usuarios/{id}")
    public ResponseEntity<Usuario> obtenerUsuarioPorId(@PathVariable Long id) {
        Usuario usuario = usuarioService.obtenerPorId(id);
        if (usuario != null) {
            return ResponseEntity.ok(usuario);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * POST /usuarios - Crear nuevo usuario
     */
    @PostMapping("/usuarios")
    public ResponseEntity<Usuario> crearUsuario(@RequestBody Usuario usuario) {
        Usuario usuarioGuardado = usuarioService.guardar(usuario);
        return ResponseEntity.status(HttpStatus.CREATED).body(usuarioGuardado);
    }

    /**
     * PUT /usuarios/{id} - Actualizar usuario
     */
    @PutMapping("/usuarios/{id}")
    public ResponseEntity<Usuario> actualizarUsuario(@PathVariable Long id, @RequestBody Usuario usuario) {
        Usuario usuarioExistente = usuarioService.obtenerPorId(id);
        if (usuarioExistente != null) {
            usuario.setId(id);
            Usuario usuarioActualizado = usuarioService.guardar(usuario);
            return ResponseEntity.ok(usuarioActualizado);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * DELETE /usuarios/{id} - Eliminar usuario
     */
    @DeleteMapping("/usuarios/{id}")
    public ResponseEntity<Void> eliminarUsuario(@PathVariable Long id) {
        Usuario usuario = usuarioService.obtenerPorId(id);
        if (usuario != null) {
            usuarioService.eliminar(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Health Check
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Backend is running");
    }

}
