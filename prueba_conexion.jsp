<%-- prueba_conexion.jsp - BORRAR al terminar el parcial --%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT COUNT(*) AS total FROM propiedad");
        rs.next();
        out.println("Conexion exitosa. Propiedades: " + rs.getInt("total"));
    } catch (SQLException ex) {
        out.println("Fallo la conexion: " + ex.getMessage());
    } finally {
        cerrar(rs, st, con);
    }
%>