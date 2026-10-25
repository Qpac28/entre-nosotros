// A real 3D confetti burst (not CSS) for the Heat-10 Finale moment.
// Spins up a temporary full-screen Three.js overlay, animates for ~2.6s, then fully
// tears itself down (canvas removed, renderer disposed) so nothing keeps running after.
const Confetti3D = (() => {
  function burst() {
    if (typeof THREE === "undefined") return;

    const canvas = document.createElement("canvas");
    canvas.style.position = "fixed";
    canvas.style.top = "0";
    canvas.style.left = "0";
    canvas.style.width = "100vw";
    canvas.style.height = "100vh";
    canvas.style.pointerEvents = "none";
    canvas.style.zIndex = "200";
    document.body.appendChild(canvas);

    const width = window.innerWidth;
    const height = window.innerHeight;

    let renderer;
    try {
      renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
    } catch (err) {
      document.body.removeChild(canvas);
      return;
    }
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(width, height);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(50, width / height, 0.1, 100);
    camera.position.z = 10;

    scene.add(new THREE.AmbientLight(0xffffff, 1));
    const light = new THREE.PointLight(0xffffff, 1.2, 50);
    light.position.set(0, 0, 8);
    scene.add(light);

    const colors = [0xe63956, 0xf4c430, 0xe2a8af, 0xff708f, 0x8fd8e0];
    const count = 160;
    const particles = [];
    const group = new THREE.Group();

    for (let i = 0; i < count; i++) {
      const geo = new THREE.PlaneGeometry(0.18, 0.1);
      const mat = new THREE.MeshBasicMaterial({
        color: colors[i % colors.length],
        side: THREE.DoubleSide,
        transparent: true
      });
      const p = new THREE.Mesh(geo, mat);
      p.position.set((Math.random() - 0.5) * 2, (Math.random() - 0.5) * 2 + 2, (Math.random() - 0.5) * 2);
      p.userData.vel = new THREE.Vector3((Math.random() - 0.5) * 6, Math.random() * 5 + 3, (Math.random() - 0.5) * 4);
      p.userData.rotVel = new THREE.Vector3((Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8);
      group.add(p);
      particles.push(p);
    }
    scene.add(group);

    const duration = 2600;
    let elapsed = 0;
    let lastTime = performance.now();

    function animate() {
      const now = performance.now();
      const dt = Math.min((now - lastTime) / 1000, 0.05);
      lastTime = now;
      elapsed += dt * 1000;

      particles.forEach((p) => {
        p.userData.vel.y -= 9.8 * dt;
        p.position.addScaledVector(p.userData.vel, dt);
        p.rotation.x += p.userData.rotVel.x * dt;
        p.rotation.y += p.userData.rotVel.y * dt;
        p.rotation.z += p.userData.rotVel.z * dt;
        if (elapsed > duration * 0.6) {
          p.material.opacity = Math.max(0, 1 - (elapsed - duration * 0.6) / (duration * 0.4));
        }
      });

      renderer.render(scene, camera);

      if (elapsed < duration) {
        requestAnimationFrame(animate);
      } else {
        particles.forEach((p) => { p.geometry.dispose(); p.material.dispose(); });
        renderer.dispose();
        document.body.removeChild(canvas);
      }
    }

    requestAnimationFrame(animate);
  }

  return { burst };
})();
