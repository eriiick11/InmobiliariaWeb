<%--
  acceso-denegado.jsp - Pagina que se muestra cuando un usuario autenticado
  intenta entrar a una seccion para la que no tiene el rol requerido.
  Requisito explicito del parcial: "el sistema lo redirige a una pagina
  de acceso denegado".
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String rolSesion = (String) session.getAttribute("rol");
    String destinoInicio = ctx + "/inicio.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acceso denegado | Raíz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh">
<div class="container" style="max-width:480px">
    <div class="card shadow-lg border-0 text-center">
        <div class="card-body p-5">
            <div class="display-1 text-warning mb-3">&#9888;</div>
            <h3 class="fw-bold mb-2">Acceso denegado</h3>
            <p class="text-muted mb-4">
                No tienes permisos para entrar a esa sección
                <% if (rolSesion != null) { %>
                    con tu rol actual (<b><%= rolSesion %></b>).
                <% } else { %>
                    sin haber iniciado sesión.
                <% } %>
            </p>
            <a href="<%= destinoInicio %>" class="btn btn-warning fw-bold">
                Volver a mi panel
            </a>
        </div>
    </div>
</div>
</body>
</html>
