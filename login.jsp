<%-- login.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Iniciar sesión | Raíz</title>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Work+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/auth.css">
</head>
<body class="auth-page">
<main class="auth-card">
  <a class="brand" href="index.jsp">Ra<span>í</span>z</a>
  <h1>Inicia sesión</h1>
  <% if (msg != null) { %><p class="auth-msg"><%= msg %></p><% } %>
  <% if (error != null) { %><p class="auth-error"><%= error %></p><% } %>
  <form method="post" action="acceso.jsp">
    <div class="field"><label for="username">Usuario</label>
      <input type="text" id="username" name="username" required autofocus></div>
    <div class="field"><label for="clave">Clave</label>
      <input type="password" id="clave" name="clave" required></div>
    <button type="submit" class="btn btn-brass">Ingresar</button>
  </form>
  <p class="auth-alt">¿No tienes cuenta? <a href="registro.jsp">Regístrate</a></p>
</main>
</body>
</html>