// Full-screen rising ember particle field, replacing the flat CSS dots.
// Falls back silently (Embers3D.init returns false) if THREE/WebGL isn't available,
// so script.js can keep using the old CSS ember loop as a backup.
const Embers3D = (() => {
  let renderer, scene, camera, points, speeds, drifts;
  let ready = false;

  function makeSprite() {
    const size = 64;
    const canvas = document.createElement("canvas");
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext("2d");
    const grad = ctx.createRadialGradient(size / 2, size / 2, 0, size / 2, size / 2, size / 2);
    grad.addColorStop(0, "rgba(255,210,180,1)");
    grad.addColorStop(0.4, "rgba(255,112,143,0.8)");
    grad.addColorStop(1, "rgba(255,112,143,0)");
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, size, size);
    return new THREE.CanvasTexture(canvas);
  }

  function init(containerEl) {
    if (typeof THREE === "undefined") return false;
    try {
      const width = window.innerWidth;
      const height = window.innerHeight;

      const canvas = document.createElement("canvas");
      canvas.style.position = "fixed";
      canvas.style.top = "0";
      canvas.style.left = "0";
      canvas.style.width = "100vw";
      canvas.style.height = "100vh";
      canvas.style.pointerEvents = "none";
      canvas.style.zIndex = "0";
      containerEl.appendChild(canvas);

      renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: false });
      renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
      renderer.setSize(width, height);

      scene = new THREE.Scene();
      camera = new THREE.OrthographicCamera(0, width, height, 0, -10, 10);

      const count = 60;
      const positions = new Float32Array(count * 3);
      speeds = new Float32Array(count);
      drifts = new Float32Array(count);

      for (let i = 0; i < count; i++) {
        positions[i * 3] = Math.random() * width;
        positions[i * 3 + 1] = Math.random() * height;
        positions[i * 3 + 2] = 0;
        speeds[i] = 10 + Math.random() * 18;
        drifts[i] = (Math.random() - 0.5) * 12;
      }

      const geometry = new THREE.BufferGeometry();
      geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));

      const material = new THREE.PointsMaterial({
        size: 9,
        map: makeSprite(),
        transparent: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        sizeAttenuation: false
      });

      points = new THREE.Points(geometry, material);
      scene.add(points);

      window.addEventListener("resize", () => {
        const w = window.innerWidth, h = window.innerHeight;
        renderer.setSize(w, h);
        camera.right = w;
        camera.top = h;
        camera.updateProjectionMatrix();
      });

      ready = true;
      animate();
      return true;
    } catch (err) {
      return false;
    }
  }

  function animate() {
    let last = performance.now();
    function frame() {
      requestAnimationFrame(frame);
      const now = performance.now();
      const dt = Math.min((now - last) / 1000, 0.05);
      last = now;

      const posAttr = points.geometry.getAttribute("position");
      const h = window.innerHeight;
      const w = window.innerWidth;
      for (let i = 0; i < posAttr.count; i++) {
        let y = posAttr.getY(i) + speeds[i] * dt;
        let x = posAttr.getX(i) + Math.sin(now * 0.001 + i) * drifts[i] * dt;
        if (y > h + 10) {
          y = -10;
          x = Math.random() * w;
        }
        posAttr.setXY(i, x, y);
      }
      posAttr.needsUpdate = true;
      renderer.render(scene, camera);
    }
    frame();
  }

  return { init, get isReady() { return ready; } };
})();
