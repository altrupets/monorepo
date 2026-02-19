// AltruPets Custom JavaScript

document.addEventListener("DOMContentLoaded", function() {
  console.log("AltruPets Docs loaded");
  
  // Agregar botón de pantalla completa a todos los diagramas Mermaid
  initMermaidFullscreen();
});

/**
 * Inicializa la funcionalidad de pantalla completa para diagramas Mermaid
 */
function initMermaidFullscreen() {
  // Esperar a que Mermaid renderice los diagramas
  setTimeout(() => {
    const mermaidDiagrams = document.querySelectorAll('.mermaid');
    
    mermaidDiagrams.forEach((diagram, index) => {
      // Crear contenedor wrapper si no existe
      if (!diagram.parentElement.classList.contains('mermaid-wrapper')) {
        const wrapper = document.createElement('div');
        wrapper.className = 'mermaid-wrapper';
        diagram.parentNode.insertBefore(wrapper, diagram);
        wrapper.appendChild(diagram);
        
        // Crear botón de pantalla completa
        const fullscreenBtn = document.createElement('button');
        fullscreenBtn.className = 'mermaid-fullscreen-btn';
        fullscreenBtn.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/>
          </svg>
        `;
        fullscreenBtn.title = 'Ver en pantalla completa';
        fullscreenBtn.setAttribute('aria-label', 'Expandir diagrama a pantalla completa');
        
        // Agregar evento click
        fullscreenBtn.addEventListener('click', () => {
          openMermaidFullscreen(diagram, index);
        });
        
        wrapper.appendChild(fullscreenBtn);
      }
    });
  }, 500);
}

/**
 * Abre un diagrama Mermaid en pantalla completa
 */
function openMermaidFullscreen(diagram, index) {
  // Crear modal de pantalla completa
  const modal = document.createElement('div');
  modal.className = 'mermaid-fullscreen-modal';
  modal.innerHTML = `
    <div class="mermaid-fullscreen-content">
      <div class="mermaid-fullscreen-header">
        <h3>Diagrama ${index + 1}</h3>
        <button class="mermaid-fullscreen-close" aria-label="Cerrar pantalla completa">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
          </svg>
        </button>
      </div>
      <div class="mermaid-fullscreen-body">
        ${diagram.outerHTML}
      </div>
      <div class="mermaid-fullscreen-footer">
        <button class="mermaid-zoom-in" aria-label="Acercar">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zm2.5-4h-2v2H9v-2H7V9h2V7h1v2h2v1z"/>
          </svg>
        </button>
        <button class="mermaid-zoom-out" aria-label="Alejar">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zM7 9h5v1H7z"/>
          </svg>
        </button>
        <button class="mermaid-zoom-reset" aria-label="Restablecer zoom">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
          </svg>
        </button>
      </div>
    </div>
  `;
  
  document.body.appendChild(modal);
  
  // Prevenir scroll del body
  document.body.style.overflow = 'hidden';
  
  // Variables para zoom y pan
  let scale = 1;
  const diagramBody = modal.querySelector('.mermaid-fullscreen-body');
  const diagramContent = diagramBody.querySelector('.mermaid');
  
  // Aplicar transformación inicial
  diagramContent.style.transformOrigin = 'center center';
  diagramContent.style.transition = 'transform 0.3s ease';
  
  // Función para actualizar zoom
  function updateZoom() {
    diagramContent.style.transform = `scale(${scale})`;
  }
  
  // Botones de zoom
  modal.querySelector('.mermaid-zoom-in').addEventListener('click', () => {
    scale = Math.min(scale + 0.2, 3);
    updateZoom();
  });
  
  modal.querySelector('.mermaid-zoom-out').addEventListener('click', () => {
    scale = Math.max(scale - 0.2, 0.5);
    updateZoom();
  });
  
  modal.querySelector('.mermaid-zoom-reset').addEventListener('click', () => {
    scale = 1;
    updateZoom();
  });
  
  // Cerrar modal
  function closeModal() {
    document.body.style.overflow = '';
    modal.remove();
  }
  
  modal.querySelector('.mermaid-fullscreen-close').addEventListener('click', closeModal);
  
  // Cerrar con ESC
  function handleEscape(e) {
    if (e.key === 'Escape') {
      closeModal();
      document.removeEventListener('keydown', handleEscape);
    }
  }
  document.addEventListener('keydown', handleEscape);
  
  // Cerrar al hacer click fuera del contenido
  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      closeModal();
    }
  });
  
  // Zoom con rueda del mouse
  diagramBody.addEventListener('wheel', (e) => {
    e.preventDefault();
    if (e.deltaY < 0) {
      scale = Math.min(scale + 0.1, 3);
    } else {
      scale = Math.max(scale - 0.1, 0.5);
    }
    updateZoom();
  });
}

