<%-- registro.jsp - Formulario publico de registro (rol CLIENTE por defecto) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String error = request.getParameter("error");
    // Repoblar campos no sensibles si venimos de un error de registrar.jsp
    // (clave/clave2 nunca se repoblan, ver registrar.jsp)
    String vDocumento = esc(request.getParameter("documento"));
    String vNombres   = esc(request.getParameter("nombres"));
    String vApellidos = esc(request.getParameter("apellidos"));
    String vCorreo    = esc(request.getParameter("correo"));
    String vUsername  = esc(request.getParameter("username"));
    String vTelefono  = esc(request.getParameter("telefono"));
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Crear cuenta | Raíz</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&family=Work+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/auth.css">
</head>
<body class="auth-page">

<div class="auth-visual" aria-hidden="true">
  <a class="brand" href="index.jsp">Ra<span>í</span>z</a>
  <blockquote>&ldquo;Crea tu cuenta y guarda cada propiedad que te interese, en un solo lugar.&rdquo;</blockquote>
  <p class="auth-visual-note">Sin costo. Cancela cuando quieras.</p>
</div>

<div class="auth-form-side">
  <main class="auth-card">
    <a class="brand" href="index.jsp">Ra<span>í</span>z</a>
    <h1>Crea tu cuenta</h1>
    <p class="auth-sub">Toma menos de un minuto.</p>
    <% if (error != null) { %>
      <p class="auth-error"><%= error %></p>
    <% } %>
    <form method="post" action="registrar.jsp">
      <div class="field"><label for="documento">Documento</label>
        <input type="text" id="documento" name="documento" required maxlength="20" value="<%= vDocumento %>"></div>
      <div class="field"><label for="nombres">Nombres</label>
        <input type="text" id="nombres" name="nombres" required maxlength="80" value="<%= vNombres %>"></div>
      <div class="field"><label for="apellidos">Apellidos</label>
        <input type="text" id="apellidos" name="apellidos" required maxlength="80" value="<%= vApellidos %>"></div>
      <div class="field"><label for="correo">Correo</label>
        <input type="email" id="correo" name="correo" required maxlength="100" value="<%= vCorreo %>"></div>
      <div class="field"><label for="username">Usuario</label>
        <input type="text" id="username" name="username" required maxlength="50" value="<%= vUsername %>"></div>
      <div class="field"><label for="telefono">Teléfono</label>
        <input type="text" id="telefono" name="telefono" maxlength="20" value="<%= vTelefono %>"></div>
      <div class="field"><label for="clave">Clave</label>
        <input type="password" id="clave" name="clave" required minlength="6"></div>
      <div class="field"><label for="clave2">Confirmar clave</label>
        <input type="password" id="clave2" name="clave2" required minlength="6"></div>
      <button type="submit" class="btn btn-brass">Crear cuenta</button>
    </form>
    <p class="auth-alt">¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión</a></p>
  </main>
</div>

</body>
</html>
