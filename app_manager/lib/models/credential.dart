class Credential {
  int? id;
  int usuarioId;
  String nombreServicio;
  String usuarioServicio;
  String passwordServicio;

  Credential({
    this.id,
    required this.usuarioId,
    required this.nombreServicio,
    required this.usuarioServicio,
    required this.passwordServicio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre_servicio': nombreServicio,
      'usuario_servicio': usuarioServicio,
      'password_servicio': passwordServicio,
    };
  }
}