<%--
  registrar.jsp - Controlador de registro.
  Inserta usuario + perfil (1:1) + usuario_rol (rol CLIENTE por defecto)
  dentro de una transaccion. No genera HTML: siempre redirige.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String documento = request.getParameter("documento");
    String nombres   = request.getParameter("nombres");
    String apellidos = request.getParameter("apellidos");
    String correo    = request.getParameter("correo");
    String username  = request.getParameter("username");
    String telefono  = request.getParameter("telefono");
    String clave     = request.getParameter("clave");
    String clave2    = request.getParameter("clave2");

    String destino = "registro.jsp";

    if (documento == null || nombres == null || apellidos == null || correo == null
        || username == null || clave == null || clave.trim().isEmpty()
        || !clave.equals(clave2)) {
        response.sendRedirect(destino + "?error="
            + java.net.URLEncoder.encode("Revisa los campos: las claves deben coincidir.", "UTF-8"));
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        // 1) usuario
        ps = con.prepareStatement(
            "INSERT INTO usuario (documento, username, correo, password_hash) VALUES (?,?,?,?)",
            Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, documento.trim());
        ps.setString(2, username.trim());
        ps.setString(3, correo.trim());
        ps.setString(4, claveCifrada(username.trim(), clave));
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        rs.next();
        int idUsuario = rs.getInt(1);
        cerrar(rs, ps);

        // 2) perfil (1:1)
        ps = con.prepareStatement(
            "INSERT INTO perfil (id_usuario, nombres, apellidos, telefono) VALUES (?,?,?,?)");
        ps.setInt(1, idUsuario);
        ps.setString(2, nombres.trim());
        ps.setString(3, apellidos.trim());
        ps.setString(4, telefono == null ? null : telefono.trim());
        ps.executeUpdate();
        cerrar(ps);

        // 3) usuario_rol: rol CLIENTE por defecto
        ps = con.prepareStatement(
            "INSERT INTO usuario_rol (id_usuario, id_rol) "
            + "SELECT ?, id_rol FROM rol WHERE nombre = 'CLIENTE'");
        ps.setInt(1, idUsuario);
        ps.executeUpdate();
        cerrar(ps);

        con.commit();
        destino = "login.jsp?msg="
            + java.net.URLEncoder.encode("Cuenta creada. Ya puedes iniciar sesion.", "UTF-8");

    } catch (SQLIntegrityConstraintViolationException ex) {
        deshacer(con);
        destino = "registro.jsp?error=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } catch (SQLException ex) {
        deshacer(con);
        destino = "registro.jsp?error=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>