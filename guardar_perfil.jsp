<%--
  guardar_perfil.jsp - Controlador de guardado del perfil (1:1).
  La fila de perfil ya existe desde el registro, asi que siempre es UPDATE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.Part, java.io.File, java.io.InputStream, java.nio.file.Files, java.util.UUID" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String nombres   = request.getParameter("nombres");
    String apellidos = request.getParameter("apellidos");
    String telefono  = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    String foto      = request.getParameter("foto_actual"); // por defecto, se conserva la que ya habia

    String destino = ctx + "/perfil.jsp";

    if (nombres == null || nombres.trim().isEmpty()
        || apellidos == null || apellidos.trim().isEmpty()) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode("Nombres y apellidos son obligatorios.", "UTF-8"));
        return;
    }

    // ---------- Foto nueva (opcional): si el usuario eligio un archivo, lo valida y guarda ----------
    Part parte = request.getPart("archivo_foto");
    if (parte != null && parte.getSize() > 0) {
        String[] extensionesPermitidas = {"jpg", "jpeg", "png", "webp"};
        String nombreOriginal = parte.getSubmittedFileName();
        String extension = "";
        if (nombreOriginal != null && nombreOriginal.contains(".")) {
            extension = nombreOriginal.substring(nombreOriginal.lastIndexOf('.') + 1).toLowerCase();
        }
        boolean extensionValida = false;
        for (String ext : extensionesPermitidas) {
            if (ext.equals(extension)) { extensionValida = true; break; }
        }
        if (!extensionValida) {
            response.sendRedirect(destino + "?err="
                + java.net.URLEncoder.encode("La foto debe ser JPG, PNG o WEBP.", "UTF-8"));
            return;
        }
        String rutaFisica = application.getRealPath("/uploads/perfiles");
        File carpeta = new File(rutaFisica);
        if (!carpeta.exists()) carpeta.mkdirs();
        String nombreEnDisco = UUID.randomUUID().toString() + "." + extension;
        try (InputStream in = parte.getInputStream()) {
            Files.copy(in, new File(carpeta, nombreEnDisco).toPath());
        }
        foto = ctx + "/uploads/perfiles/" + nombreEnDisco;
    }

    Connection con = null; PreparedStatement ps = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "UPDATE perfil SET nombres = ?, apellidos = ?, telefono = ?, direccion = ?, foto = ? "
          + "WHERE id_usuario = ?");
        ps.setString(1, nombres.trim());
        ps.setString(2, apellidos.trim());
        ps.setString(3, (telefono == null || telefono.trim().isEmpty()) ? null : telefono.trim());
        ps.setString(4, (direccion == null || direccion.trim().isEmpty()) ? null : direccion.trim());
        ps.setString(5, (foto == null || foto.trim().isEmpty()) ? null : foto.trim());
        ps.setInt(6, idUsuarioSesion);
        ps.executeUpdate();
        cerrar(ps);

        // La sesion guarda el nombre para mostrarlo en la cabecera; se refresca aqui.
        session.setAttribute("nombre", nombres.trim() + " " + apellidos.trim());

        destino += "?msg=" + java.net.URLEncoder.encode("Perfil actualizado.", "UTF-8");
    } catch (SQLException ex) {
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
