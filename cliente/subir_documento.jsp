<%--
  cliente/subir_documento.jsp - Controlador (solo POST) para radicar un
  documento sobre una solicitud propia que siga PENDIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.Part, java.io.File, java.io.InputStream, java.nio.file.Files, java.util.UUID" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
    String destino = ctx + "/cliente/mis_solicitudes.jsp";

    String[] extensionesPermitidas = {"pdf", "jpg", "jpeg", "png"};
    Part parte = request.getPart("archivo_documento");
    String nombreOriginal = (parte != null) ? parte.getSubmittedFileName() : null;
    String extension = "";
    if (nombreOriginal != null && nombreOriginal.contains(".")) {
        extension = nombreOriginal.substring(nombreOriginal.lastIndexOf('.') + 1).toLowerCase();
    }
    boolean extensionValida = false;
    for (String ext : extensionesPermitidas) {
        if (ext.equals(extension)) { extensionValida = true; break; }
    }

    if (parte == null || parte.getSize() == 0 || !extensionValida) {
        response.sendRedirect(destino + "?err=" + java.net.URLEncoder.encode(
            "Selecciona un archivo PDF, JPG o PNG valido.", "UTF-8"));
        return;
    }

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        // La solicitud debe ser del cliente en sesion y seguir PENDIENTE
        ps = con.prepareStatement(
            "SELECT estado FROM solicitud WHERE id_solicitud = ? AND id_cliente = ?");
        ps.setInt(1, idSolicitud);
        ps.setInt(2, idUsuarioSesion);
        rs = ps.executeQuery();
        boolean puedeSubir = rs.next() && "PENDIENTE".equals(rs.getString("estado"));
        cerrar(rs, ps);

        if (!puedeSubir) {
            response.sendRedirect(destino + "?err="
                + java.net.URLEncoder.encode("Esa solicitud no admite mas documentos.", "UTF-8"));
            return;
        }

        String rutaFisica = application.getRealPath("/uploads/documentos");
        File carpeta = new File(rutaFisica);
        if (!carpeta.exists()) carpeta.mkdirs();

        String nombreEnDisco = UUID.randomUUID().toString() + "." + extension;
        File archivoDestino = new File(carpeta, nombreEnDisco);
        try (InputStream in = parte.getInputStream()) {
            Files.copy(in, archivoDestino.toPath());
        }
        String urlArchivo = ctx + "/uploads/documentos/" + nombreEnDisco;

        ps = con.prepareStatement(
            "INSERT INTO documento_solicitud (id_solicitud, nombre_archivo, url_archivo) VALUES (?, ?, ?)");
        ps.setInt(1, idSolicitud);
        ps.setString(2, nombreOriginal);
        ps.setString(3, urlArchivo);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(destino + "?msg="
            + java.net.URLEncoder.encode("Documento radicado.", "UTF-8"));

    } catch (SQLException ex) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
