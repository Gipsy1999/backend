import React from 'react';
import '../styles/Nosotros.css';

export default function Nosotros() {
  return (
    <main className="container">
      <h2 className="section-title">Nosotros</h2>
      <p>
        Somos Level-Up Gamer, una tienda chilena dedicada al mundo gamer.  
        Nuestra misión es ofrecer productos de calidad con experiencia personalizada.  
        Nuestra visión es ser líderes en innovación y fidelización en el mercado gamer.
      </p>

      <div className="nosotros-video-container">
        <video controls width="100%">
          <source src="/assets/media/never.mp4" type="video/mp4" />
          Tu navegador no soporta el video.
        </video>
      </div>
    </main>
  );
}
