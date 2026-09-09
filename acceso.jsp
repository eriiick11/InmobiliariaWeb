<%--
  acceso.jsp - Valida credenciales, arma la sesion con TODOS los roles del
  usuario (usuario_rol es N:M) y redirige segun el rol de mayor jerarquia.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String clave = request.getParameter("clave");

    if (username == null || clave == null || username.trim().isEmpty() || clave.trim().isEmpty()) {
        response.sendRedirect("login.jsp?error="
            + java.net.URLEncoder.encode("Escribe el usuario y la clave.", "UTF-8"));
        return;
    }
    username = username.trim();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT u.id_usuario, u.password_hash, u.activo, p.nombres, p.apellidos "
            + "FROM usuario u JOIN perfil p ON p.id_usuario = u.id_usuario "
            + "WHERE u.username = ?");
        ps.setString(1, username);
        rs = ps.executeQuery();

        if (!rs.next()) {
            response.sendRedirect("login.jsp?error="
                + java.net.URLEncoder.encode("Usuario o clave incorrectos.", "UTF-8"));
            return;
        }

        boolean activo = rs.getBoolean("activo");
        if (!activo) {
            response.sendRedirect("login.jsp?error="
                + java.net.URLEncoder.encode("El usuario esta inhabilitado.", "UTF-8"));
            return;
        }

        if (!rs.getString("password_hash").equals(claveCifrada(username, clave))) {
            response.sendRedirect("login.jsp?error="
                + java.net.URLEncoder.encode("Usuario o clave incorrectos.", "UTF-8"));
            return;
        }

        int idUsuario = rs.getInt("id_usuario");
        String nombreCompleto = rs.getString("nombres") + " " + rs.getString("apellidos");
        cerrar(rs, ps);

        // Roles del usuario (N:M) — un usuario puede tener varios
        ps = con.prepareStatement(
            "SELECT r.nombre FROM usuario_rol ur "
            + "JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        List<String> roles = new ArrayList<String>();
        while (rs.next()) roles.add(rs.getString("nombre"));
        cerrar(rs, ps);

        if (roles.isEmpty()) {
            response.sendRedirect("login.jsp?error="
                + java.net.URLEncoder.encode("El usuario no tiene un rol asignado.", "UTF-8"));
            return;
        }

        // Jerarquia para decidir el "rol principal" (a donde redirige tras login)
        String[] prioridad = {"ADMINISTRADOR", "INMOBILIARIA", "CLIENTE"};
        String rolPrincipal = roles.get(0);
        for (String p : prioridad) {
            if (roles.contains(p)) { rolPrincipal = p; break; }
        }

        session.setAttribute("idUsuario", idUsuario);
        session.setAttribute("nombre", nombreCompleto);
        session.setAttribute("username", username);
        session.setAttribute("roles", roles);        // lista completa
        session.setAttribute("rol", rolPrincipal);    // rol activo/principal
        session.setMaxInactiveInterval(30 * 60);

        response.sendRedirect("inicio.jsp");

    } catch (SQLException ex) {
        response.sendRedirect("login.jsp?error="
            + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>