import React from 'react';
import { Link } from 'react-router-dom';
import '../styles/Footer.css';

export default function Footer() {
  return (
    <footer className="footer text-center text-lg-start mt-5 border-top">
      <div className="container p-4">
        <div className="row align-items-start">
          <div className="col-md-6 d-flex flex-column align-items-start mb-3 mb-md-0">
            <div className="mb-2">
              <Link to="/noticias" className="text-decoration-none mx-3 footer-label">Noticias</Link>
              <Link to="/contacto" className="text-decoration-none mx-3 footer-label">Contacto</Link>
              <Link to="/nosotros" className="text-decoration-none mx-3 footer-label">Nosotros</Link>
            </div>
            <ul className="text-dark small mt-2 ms-3 list-unstyled mb-0">
              <li><strong>Email:</strong> contacto@levelup.com</li>
              <li><strong>Teléfono:</strong> +56 9 1234 5678</li>
              <li><strong>Horario:</strong> Lunes a Viernes, 9:00 - 18:00</li>
              <li><strong>Dirección:</strong> Calle Falsa 123, Santiago, Chile</li>
            </ul>
          </div>
          <div className="col-md-6 d-flex flex-column align-items-end justify-content-end">
            <div className="d-flex align-items-center mb-2">
              <span className="fw-bold footer-label me-2">Síguenos:</span>
              <a href="https://facebook.com" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/facebook.png" alt="Facebook" width="32" height="32" />
              </a>
              <a href="https://instagram.com" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/instagram.png" alt="Instagram" width="32" height="32" />
              </a>
              <a href="https://twitter.com" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/x.png" alt="Twitter" width="32" height="32" />
              </a>
              <a href="https://tiktok.com" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/tik-tok.png" alt="TikTok" width="32" height="32" />
              </a>
              <a href="https://youtube.com" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/youtube.png" alt="YouTube" width="32" height="32" />
              </a>
            </div>
            <div className="d-flex align-items-center">
              <span className="fw-bold footer-label me-2">Contáctanos:</span>
              <a href="https://wa.me/+56921693028?text=Bienvenido%20al%20chat%20de%20servico%20al%20cliente%20de%20Level%20UP,%20Habla%20Con%20nosotros!" target="_blank" rel="noopener noreferrer" className="mx-1">
                <img src="/assets/icons/whatsapp.png" alt="WhatsApp" width="32" height="32" />
              </a>
            </div>
          </div>
        </div>
        <div className="text-center mt-3 text-muted footer-copyright">
          &copy; {new Date().getFullYear()} Level Up. Todos los derechos reservados.
        </div>
      </div>
    </footer>
  );
}
