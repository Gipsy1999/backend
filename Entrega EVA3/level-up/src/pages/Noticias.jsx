import React, { useState, useEffect } from 'react';
import '../styles/Noticias.css';

export default function Noticias() {
  const [noticias, setNoticias] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [filtroCategoria, setFiltroCategoria] = useState('todas');

  useEffect(() => {
    cargarNoticias();
    
    const script = document.createElement('script');
    script.src = 'https://platform.twitter.com/widgets.js';
    script.async = true;
    script.charset = 'utf-8';
    document.body.appendChild(script);
    
    return () => {
      if (document.body.contains(script)) {
        document.body.removeChild(script);
      }
    };
  }, []);

  const cargarNoticias = async () => {
    setCargando(true);
    try {
      const noticiasSimuladas = [
        {
          id: 1,
          titulo: "Ninjala estrena el episodio 189 de su anime oficial",
          descripcion: "El popular juego free-to-play de Nintendo Switch continúa expandiendo su universo con un nuevo episodio de su serie animada.",
          fecha: "2024-10-24",
          categoria: "Nintendo",
          imagen: "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=400",
          fuente: "Nintenderos",
          enlace: "https://www.nintenderos.com/2025/10/ninjala-estrena-el-episodio-189-de-su-anime-oficial/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 2,
          titulo: "Oppidum: Este prometedor título inspirado en Zelda confirma su estreno en Nintendo Switch",
          descripcion: "Así es Oppidum y otros juegos que llegarán a la consola. Un nuevo juego de aventuras que promete capturar la esencia de la legendaria saga.",
          fecha: "2024-10-24",
          categoria: "Nintendo",
          imagen: "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=400",
          fuente: "Nintenderos",
          enlace: "https://www.nintenderos.com/2025/10/este-prometedor-titulo-inspirado-en-zelda-confirma-su-estreno-en-nintendo-switch-asi-es-oppidum-y-otros-juegos-que-llegaran-a-la-consola/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 3,
          titulo: "Leyendas Pokémon Z-A supera en ventas al debut de Leyendas Pokémon Arceus en Japón",
          descripcion: "Comparativa: El nuevo juego de Pokémon ha logrado cifras impresionantes en su lanzamiento, superando al exitoso Arceus.",
          fecha: "2024-10-24",
          categoria: "Nintendo",
          imagen: "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=400",
          fuente: "Nintenderos",
          enlace: "https://www.nintenderos.com/nintendo-switch-2/leyendas-pokemon-z-a-supera-en-ventas-al-debut-de-leyendas-pokemon-arceus-en-japon-comparativa/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 4,
          titulo: "Sony cambia su estrategia de hardware para PlayStation: nueva dirección empresarial",
          descripcion: "Sony anuncia cambios importantes en su estrategia de desarrollo de hardware para la marca PlayStation que podrían redefinir el futuro de la consola.",
          fecha: "2024-10-24",
          categoria: "PlayStation",
          imagen: "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/equipos/sony-hardware-playstation-nueva-estrategia/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 5,
          titulo: "Nuevo libro de PlayStation revela información sobre prototipos y diseños nunca vistos",
          descripcion: "Una publicación oficial documenta la historia del hardware de PlayStation con imágenes exclusivas de prototipos y decisiones de diseño.",
          fecha: "2024-10-23",
          categoria: "PlayStation",
          imagen: "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/equipos/libro-playstation-informacion-prototipos-disenos/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 6,
          titulo: "PlayStation 6 portátil: los rumores apuntan a un nuevo diseño híbrido",
          descripcion: "Nuevas filtraciones sugieren que Sony podría estar trabajando en una versión portátil de PS6, combinando potencia de sobremesa con movilidad.",
          fecha: "2024-10-22",
          categoria: "PlayStation",
          imagen: "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/equipos/playstation-6-portatil-rumores/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 7,
          titulo: "Xbox disponibles 5 juegos de los Free Play Days para el fin de semana",
          descripcion: "Microsoft anuncia los títulos gratuitos que podrás jugar este fin de semana sin necesidad de suscripción.",
          fecha: "2024-10-24",
          categoria: "Xbox",
          imagen: "https://images.unsplash.com/photo-1605901309584-818e25960a8f?w=400",
          fuente: "LevelUp",
          enlace: "https://www.levelup.com/noticia/xbox-disponibles-5-juegos-de-los-free-play-days-para-el-fin-de-semana/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 8,
          titulo: "Xbox sería multiplataforma: las exclusividades de videojuegos son anticuadas, afirma directiva de la compañía",
          descripcion: "Una alta ejecutiva de Microsoft sugiere que el futuro de Xbox podría incluir lanzamientos multiplataforma, dejando atrás las exclusivas tradicionales.",
          fecha: "2024-10-23",
          categoria: "Xbox",
          imagen: "https://images.unsplash.com/photo-1605901309584-818e25960a8f?w=400",
          fuente: "LevelUp",
          enlace: "https://www.levelup.com/noticia/xbox-seria-multiplataforma-las-exclusividades-de-videojuegos-son-anticuadas-afirma-directiva-de-la-compania/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 9,
          titulo: "Decisión de Microsoft complicaría el futuro de Xbox: reporte revela el motivo detrás de los aumentos de precios, despidos y cancelaciones",
          descripcion: "Un nuevo reporte analiza las polémicas decisiones de Microsoft y su impacto en el ecosistema de Xbox y la industria de videojuegos.",
          fecha: "2024-10-22",
          categoria: "Xbox",
          imagen: "https://images.unsplash.com/photo-1605901309584-818e25960a8f?w=400",
          fuente: "LevelUp",
          enlace: "https://www.levelup.com/noticia/decision-de-microsoft-complicaria-el-futuro-de-xbox-reporte-revela-el-motivo-detras-de-los-aumentos-de-precios-despidos-y-cancelaciones/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 10,
          titulo: "AMD revela el precio de lanzamiento de Radeon AI Pro R9700",
          descripcion: "Conoce todos los detalles sobre la nueva tarjeta gráfica profesional de AMD con capacidades de IA y su precio oficial de lanzamiento.",
          fecha: "2024-10-24",
          categoria: "PC Gaming",
          imagen: "https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/tarjetas-graficas/amd-precio-lanzamiento-radeon-ai-pro-r9700/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 11,
          titulo: "Gaming Copilot: opciones para desactivar el entrenamiento de IA",
          descripcion: "Descubre cómo configurar Gaming Copilot para proteger tu privacidad y evitar que tus datos se utilicen para entrenar modelos de inteligencia artificial.",
          fecha: "2024-10-23",
          categoria: "PC Gaming",
          imagen: "https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/inteligencia-artificial/gaming-copilot-opciones-desactivar-entrenamiento-ia/",
          esTweet: false,
          esEmbebido: true
        },
        {
          id: 12,
          titulo: "GXT Trust lanza su nuevo combo gaming con baja latencia",
          descripcion: "Trust Gaming presenta su nueva línea GXT de periféricos con tecnología de baja latencia para mejorar el rendimiento en tus partidas.",
          fecha: "2024-10-22",
          categoria: "PC Gaming",
          imagen: "https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=400",
          fuente: "HardZone",
          enlace: "https://hardzone.es/noticias/perifericos/gxtrust-combo-gaming-baja-latencia/",
          esTweet: false,
          esEmbebido: true
        }
      ];

      setNoticias(noticiasSimuladas);
    } catch (error) {
      if (window.notificar) {
        window.notificar('Error al cargar las noticias', 'error', 3000);
      }
    } finally {
      setCargando(false);
    }
  };

  const categorias = ['todas', ...new Set(noticias.map(n => n.categoria))];

  const noticiasFiltradas = filtroCategoria === 'todas' 
    ? noticias 
    : noticias.filter(n => n.categoria === filtroCategoria);

  const formatearFecha = (fecha) => {
    const date = new Date(fecha);
    return date.toLocaleDateString('es-CL', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <main className="container noticias-page">
      <h2 className="section-title">Noticias de Videojuegos</h2>
      <p className="text-center text-secondary mb-4">
        Mantente al día con las últimas novedades del mundo gaming
      </p>

      <div className="filtros-noticias mb-4">
        <div className="d-flex gap-2 flex-wrap justify-content-center">
          {categorias.map(categoria => (
            <button
              key={categoria}
              className={`btn ${filtroCategoria === categoria ? 'btn-success' : 'btn-outline-success'}`}
              onClick={() => setFiltroCategoria(categoria)}
            >
              {categoria.charAt(0).toUpperCase() + categoria.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {cargando ? (
        <div className="text-center py-5">
          <div className="spinner-border noticias-spinner" role="status">
            <span className="visually-hidden">Cargando...</span>
          </div>
          <p className="text-secondary mt-3">Cargando noticias...</p>
        </div>
      ) : (
        <div className="row">
          {noticiasFiltradas.map(noticia => (
            <div key={noticia.id} className={noticia.esEmbebido ? "col-12 mb-4" : "col-md-6 col-lg-4 mb-4"}>
              {noticia.esTweet ? (
                <div className="tweet-embed-container">
                  <blockquote className="twitter-tweet" data-theme="dark">
                    <p lang="es" dir="ltr">
                      No te pierdas el vídeo de introducción de la escapada, un modo historia para un jugador que se acaba de anunciar para <a href="https://twitter.com/hashtag/KirbyAirRiders?src=hash&amp;ref_src=twsrc%5Etfw">#KirbyAirRiders</a>. 
                      <a href="https://t.co/abc123def456">pic.twitter.com/abc123def456</a>
                    </p>
                    &mdash; Nintendo España (@NintendoES) <a href={`https://twitter.com/NintendoES/status/${noticia.tweetId}?ref_src=twsrc%5Etfw`}>23 de octubre de 2025</a>
                  </blockquote>
                </div>
              ) : noticia.esEmbebido ? (
                <div className="noticia-embebida">
                  <div className="noticia-embebida-header">
                    <h5 className="mb-2">{noticia.titulo}</h5>
                    <div className="d-flex justify-content-between align-items-center mb-3">
                      <span className="badge bg-success">{noticia.categoria}</span>
                      <small className="noticias-fecha">{formatearFecha(noticia.fecha)}</small>
                      <small className="text-secondary">{noticia.fuente}</small>
                    </div>
                  </div>
                  <div className="iframe-container">
                    <iframe 
                      src={noticia.enlace}
                      title={noticia.titulo}
                      frameBorder="0"
                      scrolling="yes"
                      allowFullScreen
                    />
                  </div>
                  <div className="noticia-embebida-footer mt-3">
                    <a 
                      href={noticia.enlace} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="btn btn-sm btn-outline-success"
                    >
                      Ver en {noticia.fuente} →
                    </a>
                  </div>
                </div>
              ) : (
                <div className="noticia-card">
                  <div className="noticia-imagen">
                    <img 
                      src={noticia.imagen} 
                      alt={noticia.titulo}
                      onError={(e) => {
                        e.target.src = '/assets/icons/icono.png';
                      }}
                    />
                    <span className="noticia-categoria badge bg-success">
                      {noticia.categoria}
                    </span>
                  </div>
                  <div className="noticia-contenido">
                    <div className="noticia-meta mb-2">
                      <small className="noticias-fecha">
                        {formatearFecha(noticia.fecha)}
                      </small>
                      <small className="text-secondary ms-2">• {noticia.fuente}</small>
                    </div>
                    <h5 className="noticia-titulo mb-2">{noticia.titulo}</h5>
                    <p className="noticia-descripcion">{noticia.descripcion}</p>
                    <div className="noticia-footer">
                      <a 
                        href={noticia.enlace} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="btn btn-sm btn-outline-success"
                      >
                        Leer más →
                      </a>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {!cargando && noticiasFiltradas.length === 0 && (
        <div className="text-center py-5">
          <p className="text-secondary">No hay noticias disponibles en esta categoría</p>
        </div>
      )}
    </main>
  );
}
