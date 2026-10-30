// Renders the card-back icon as a real lit 3D gem/goblet/heart instead of a flat SVG.
// Falls back silently (Icon3D.isReady stays false) if THREE or WebGL isn't available,
// so script.js can keep using the flat SVG icons as a backup.
const Icon3D = (() => {
  let renderer, scene, camera, mesh, pointLight, glowSprite;
  let ready = false;
  let tiltX = 0;
  let tiltTarget = 0;
  let spinVelocity = 0;
  let dragging = false;
  let moved = false;
  let startX = 0;
  let startY = 0;
  let lastX = 0;
  let lastY = 0;

  // Same tier+type -> gradient-name mapping script.js's ICONS object uses for the flat
  // SVG fallback, so both renderers draw from the one set of gradients defined in
  // index.html instead of keeping two independently hand-picked color tables.
  const keyToGradientName = {
    t1Truth: "gradWine",
    t1Dare: "gradIce",
    t1Drink: "gradWine",
    t2Truth: "gradGold",
    t2Dare: "gradRose",
    t2Drink: "gradGold",
    t3Truth: "gradFlame",
    t3Dare: "gradGold",
    t3Drink: "gradFlame",
    custom: "gradRose",
    finale: "gradFlame",
    t4Truth: "gradExtreme",
    t4Dare: "gradExtreme",
    t4Drink: "gradExtreme"
  };
  const colorCache = {};

  function resolveGradientColor(gradientName) {
    if (colorCache[gradientName] !== undefined) return colorCache[gradientName];
    const gradEl = document.getElementById(gradientName);
    const stops = gradEl ? gradEl.querySelectorAll("stop") : [];
    const midStop = stops[Math.floor(stops.length / 2)] || stops[0];
    const hex = midStop ? midStop.getAttribute("stop-color") : "#e2a8af";
    const color = parseInt((hex || "#e2a8af").replace("#", "0x"), 16);
    colorCache[gradientName] = color;
    return color;
  }

  const shapeByType = {
    Truth: "heart",
    Dare: "spike",
    Drink: "goblet",
    Wildcard: "spike"
  };

  function makeGlowTexture() {
    const size = 128;
    const canvas = document.createElement("canvas");
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext("2d");
    const grad = ctx.createRadialGradient(size / 2, size / 2, 0, size / 2, size / 2, size / 2);
    grad.addColorStop(0, "rgba(255,255,255,0.9)");
    grad.addColorStop(0.4, "rgba(255,255,255,0.35)");
    grad.addColorStop(1, "rgba(255,255,255,0)");
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, size, size);
    return new THREE.CanvasTexture(canvas);
  }

  function buildGeometry(shape) {
    if (shape === "heart") {
      const s = new THREE.Shape();
      s.moveTo(0, 0.4);
      s.bezierCurveTo(0, 0.6, -0.5, 0.9, -0.9, 0.5);
      s.bezierCurveTo(-1.3, 0.1, -0.9, -0.5, 0, -1.1);
      s.bezierCurveTo(0.9, -0.5, 1.3, 0.1, 0.9, 0.5);
      s.bezierCurveTo(0.5, 0.9, 0, 0.6, 0, 0.4);
      return new THREE.ExtrudeGeometry(s, {
        depth: 0.45, bevelEnabled: true, bevelThickness: 0.08,
        bevelSize: 0.08, bevelSegments: 4, curveSegments: 16
      });
    }
    if (shape === "goblet") {
      const pts = [
        new THREE.Vector2(0, -1.1), new THREE.Vector2(0.35, -1.1),
        new THREE.Vector2(0.08, -1.0), new THREE.Vector2(0.06, -0.3),
        new THREE.Vector2(0.55, 0.4), new THREE.Vector2(0.5, 0.9),
        new THREE.Vector2(0, 1.0)
      ];
      return new THREE.LatheGeometry(pts, 32);
    }
    return new THREE.IcosahedronGeometry(1, 0);
  }

  function init(stageEl, innerEl) {
    if (typeof THREE === "undefined") return false;
    try {
      const width = innerEl.clientWidth || 100;
      const height = innerEl.clientHeight || 100;

      renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
      renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
      renderer.setSize(width, height);
      innerEl.innerHTML = "";
      innerEl.appendChild(renderer.domElement);

      scene = new THREE.Scene();
      camera = new THREE.PerspectiveCamera(35, width / height, 0.1, 100);
      camera.position.set(0, 0, 4.2);

      scene.add(new THREE.AmbientLight(0xffffff, 0.35));

      const key = new THREE.DirectionalLight(0xffffff, 0.9);
      key.position.set(2, 3, 4);
      scene.add(key);

      pointLight = new THREE.PointLight(0xffffff, 1.4, 10);
      pointLight.position.set(-2, -1, 3);
      scene.add(pointLight);

      const glowMaterial = new THREE.SpriteMaterial({
        map: makeGlowTexture(),
        color: 0xe2a8af,
        transparent: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending
      });
      glowSprite = new THREE.Sprite(glowMaterial);
      glowSprite.scale.set(3.4, 3.4, 1);
      glowSprite.position.set(0, 0, -0.6);
      scene.add(glowSprite);

      attachDrag(stageEl);
      ready = true;
      animate();
      return true;
    } catch (err) {
      ready = false;
      return false;
    }
  }

  function setCard(iconKey, type) {
    if (!ready) return;
    const color = resolveGradientColor(keyToGradientName[iconKey] || "gradRose");
    const shape = shapeByType[type] || "spike";
    const geometry = buildGeometry(shape);
    geometry.center();
    geometry.computeBoundingSphere();
    const scale = 1 / (geometry.boundingSphere.radius || 1);

    if (mesh) {
      scene.remove(mesh);
      mesh.geometry.dispose();
      mesh.material.dispose();
    }

    const material = new THREE.MeshPhysicalMaterial({
      color: color,
      metalness: 0.15,
      roughness: 0.25,
      clearcoat: 0.9,
      clearcoatRoughness: 0.15,
      emissive: color,
      emissiveIntensity: 0.15
    });
    mesh = new THREE.Mesh(geometry, material);
    mesh.scale.setScalar(scale * 1.1);
    mesh.rotation.x = tiltX;
    scene.add(mesh);
    pointLight.color.setHex(color);
    glowSprite.material.color.setHex(color);
  }

  function attachDrag(stage) {
    stage.addEventListener("pointerdown", (e) => {
      e.stopPropagation();
      dragging = true;
      moved = false;
      startX = lastX = e.clientX;
      startY = lastY = e.clientY;
    });

    stage.addEventListener("pointermove", (e) => {
      if (!dragging) return;
      const dx = e.clientX - lastX;
      lastX = e.clientX;
      lastY = e.clientY;
      if (Math.abs(e.clientX - startX) > 4 || Math.abs(e.clientY - startY) > 4) moved = true;
      spinVelocity += dx * 0.002;
      tiltTarget = Math.max(-0.5, Math.min(0.5, -(e.clientY - startY) * 0.01));
    });

    const endDrag = (e) => {
      if (!dragging) return;
      e.stopPropagation();
      if (!moved) spinVelocity += 0.5;
      dragging = false;
      tiltTarget = 0;
    };

    stage.addEventListener("pointerup", endDrag);
    stage.addEventListener("pointerleave", endDrag);
  }

  function animate() {
    requestAnimationFrame(animate);
    if (mesh) {
      tiltX += (tiltTarget - tiltX) * 0.12;
      spinVelocity *= 0.94;
      mesh.rotation.x = tiltX;
      mesh.rotation.y += 0.004 + spinVelocity;
    }
    renderer.render(scene, camera);
  }

  return {
    init,
    setCard,
    get isReady() { return ready; }
  };
})();
