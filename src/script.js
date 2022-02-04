import './style.css'
import * as dat from 'lil-gui'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
//import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js'
import { gsap } from 'gsap'

/**
 * Base
 */
// Debug
/*
const gui = new dat.GUI({
    width: 400
})
*/

// Canvas
const canvas = document.querySelector('canvas.webgl')


// Scene
const scene = new THREE.Scene()
scene.background = new THREE.Color( 0xb9bfcd );


/**
 * Overlay
 */
/*
 const overlayGeometry = new THREE.PlaneGeometry(2, 2, 1, 1)
 const overlayMaterial = new THREE.ShaderMaterial({
     // wireframe: true,
     transparent: true,
     uniforms:
     {
         uAlpha: { value: 1 }
     },
     vertexShader: `
         void main()
         {
             gl_Position = vec4(position, 1.0);
         }
     `,
     fragmentShader: `
         uniform float uAlpha;
 
         void main()
         {
             gl_FragColor = vec4(0.0, 0.0, 0.0, uAlpha);
         }
     `
 })
 const overlay = new THREE.Mesh(overlayGeometry, overlayMaterial)
 //overlay.name = "_overlay"
 scene.add(overlay)
*/


/**
 * Loaders
 */
 const loadingOverlay = document.querySelector('.overlay')
 const loadingBarElement = document.querySelector('.loading-bar')
 const loadingManager = new THREE.LoadingManager(
     // Loaded
     () =>
     {
         // Wait a little
         window.setTimeout(() =>
         {
             // Animate overlay
             //gsap.to(loadingOverlay.opacity, { duration: 3, value: 0, delay: 1, onComplete: ()=>{
                 //console.log("XXX")
                 //scene.remove(overlay)
             //}})
 
             loadingOverlay.classList.add('pointer_events_none')

             gsap.to(".overlay", {
                duration: 3,
                delay: 0,
                opacity:  0,
                onComplete: ()=>{
                    //loadingOverlay.classList.add('display_hidden')
                }
             })

             //loadingOverlay.classList.add('ended')
             // Update loadingBarElement
             loadingBarElement.classList.add('ended')
             loadingBarElement.style.transform = ''
         }, 500)
     },
 
     // Progress
     (itemUrl, itemsLoaded, itemsTotal) =>
     {
         // Calculate the progress and update the loadingBarElement
         const progressRatio = itemsLoaded / itemsTotal
         loadingBarElement.style.transform = `scaleX(${progressRatio})`
     }
 )
// Texture loader
const textureLoader = new THREE.TextureLoader(loadingManager)

// Draco loader
//const dracoLoader = new DRACOLoader()
//dracoLoader.setDecoderPath('draco/')

// GLTF loader
const gltfLoader = new GLTFLoader()
//gltfLoader.setDRACOLoader(dracoLoader)

//const bakedTexture = textureLoader.load("baked.jpg")
//const bakedTexture = textureLoader.load("Episode2_ultralow_poly_baked.jpg")
//const bakedTexture = textureLoader.load("Episode2_ultralow_poly_baked.png")
//bakedTexture.flipY = false
//bakedTexture.encoding = THREE.sRGBEncoding

const terrain_baked_texture = textureLoader.load("UVTerrain.jpg")
terrain_baked_texture.flipY = false
terrain_baked_texture.encoding = THREE.sRGBEncoding

const trees_baked_texture = textureLoader.load("UVTrees.jpg")
trees_baked_texture.flipY = false
trees_baked_texture.encoding = THREE.sRGBEncoding

const rocks_baked_texture = textureLoader.load("UVRocks.jpg")
rocks_baked_texture.flipY = false
rocks_baked_texture.encoding = THREE.sRGBEncoding

const floor_baked_texture = textureLoader.load("UVFloor_small.jpg")
floor_baked_texture.flipY = false
floor_baked_texture.encoding = THREE.sRGBEncoding

/**
 * Object
 */
/*
const cube = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1, 1),
    new THREE.MeshBasicMaterial()
)
scene.add(cube)
*/


// BAKED MATERIAL
//const bakedMaterial = new THREE.MeshBasicMaterial({map: bakedTexture})
const terrain_material = new THREE.MeshBasicMaterial({map: terrain_baked_texture})
const trees_material = new THREE.MeshBasicMaterial({map: trees_baked_texture})
const rocks_material = new THREE.MeshBasicMaterial({map: rocks_baked_texture})
const floor_material = new THREE.MeshBasicMaterial({map: floor_baked_texture})

//const temp_river_material = new THREE.MeshBasicMaterial({color: 0x0033ff})
const temp_river_material = new THREE.MeshPhongMaterial({
    color: 0x0033ff,
    transparent: true,
    opacity: 0.8,
    flatShading: true,
    specular: 0x555555,
    shininess: 80,
})

/*
const cube = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1, 1),
    temp_river_material
)
cube.position.x = 0
cube.position.y = 0
cube.position.z = 0
scene.add(cube)
*/




const ambientLight = new THREE.AmbientLight(0xffffff, 0.1)
scene.add(ambientLight)


var directionalLight = new THREE.DirectionalLight( 0xffffff, 0.3);
directionalLight.position.set( -4, 2, -5 );
scene.add(directionalLight);



/* HELPERS */
//const helper = new THREE.DirectionalLightHelper( directionalLight, 5 );
//scene.add( helper );

//const axesHelper = new THREE.AxesHelper( 5 );
//scene.add( axesHelper );

/*
const pointLight = new THREE.PointLight(0xFF0000 , 3, 1);
pointLight.position.set(0,15,-5);
scene.add(pointLight);

const pointLight_helper = new THREE.PointLightHelper( pointLight, 5 );
scene.add( pointLight_helper );
*/


// Portal MAterial
//const portalLightMaterial = new THREE.MeshBasicMaterial({color: 0xd0daff})

//const poleLightMaterial = new THREE.MeshBasicMaterial({color: 0xffffe5})
//const poleLightMaterial = new THREE.MeshBasicMaterial({color: 0xfff4d9})

// MODEL

gltfLoader.load(
    //'portal.glb',
    //'Episode 2_ultralow_poly.glb',
    'GeometryTerrain.glb',
    (gltf) =>{
        console.log(gltf.scene)

        gltf.scene.traverse((child) =>{
            //child.material = bakedMaterial
            child.material = terrain_material
        }) 

        //const portalLightMesh = gltf.scene.children.find(child => child.name === "portalLight")
        //const poleLightAMesh = gltf.scene.children.find(child => child.name === "poleLightA")
        //const poleLightBMesh = gltf.scene.children.find(child => child.name === "poleLightB")
        //console.log(poleLightAMesh)
        //
        //poleLightAMesh.material = poleLightMaterial 
        //poleLightBMesh.material = poleLightMaterial 
        //portalLightMesh.material = portalLightMaterial
        

        scene.add(gltf.scene)
    }
)
gltfLoader.load(
    'GeometryTrees.glb',
    (gltf) =>{
        gltf.scene.traverse((child) =>{
            //child.material = bakedMaterial
            child.material = trees_material
        }) 
        scene.add(gltf.scene)
    }
)
gltfLoader.load(
    'GeometryRocks.glb',
    (gltf) =>{
        gltf.scene.traverse((child) =>{
            //child.material = bakedMaterial
            child.material = rocks_material
        }) 
        scene.add(gltf.scene)
    }
)
gltfLoader.load(
    'GeometryFloor.glb',
    (gltf) =>{
        gltf.scene.traverse((child) =>{
            //child.material = bakedMaterial
            child.material = floor_material
        }) 
        scene.add(gltf.scene)
    }
)

gltfLoader.load(
    'GeometryRiver.glb',
    (gltf) =>{
        gltf.scene.traverse((child) =>{
            //child.material = bakedMaterial
            child.material = temp_river_material
        }) 
        scene.add(gltf.scene)
    }
)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.outputEncoding = THREE.sRGBEncoding
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(45, sizes.width / sizes.height, 0.1, 100)
camera.position.x = 12
camera.position.y = 6
camera.position.z = 7.5
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true
controls.maxPolarAngle = Math.PI / 2.1

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.outputEncoding = THREE.sRGBEncoding

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()