const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

const API_URL = "https://api.venice.ai/api/v1/image/generate";
const API_KEY = "3EEoc4Iz3XMOI0pt63PGY_xNhtyv0ksMjYVddQWWBm"; // Replace with your actual API key



const styles = [
    '3D Model', 'Analog Film', 'Anime', 'Cinematic', 'Comic Book',
    'Craft Clay', 'Digital Art', 'Enhance', 'Fantasy Art', 'Isometric Style',
    'Line Art', 'Lowpoly', 'Neon Punk', 'Origami', 'Photographic',
    'Pixel Art', 'Texture', 'Advertising', 'Food Photography', 'Real Estate',
    'Abstract', 'Cubist', 'Graffiti', 'Hyperrealism', 'Impressionist',
    'Pointillism', 'Pop Art', 'Psychedelic', 'Renaissance', 'Steampunk',
    'Surrealist', 'Typography', 'Watercolor', 'Fighting Game', 'GTA',
    'Super Mario', 'Minecraft', 'Pokemon', 'Retro Arcade', 'Retro Game',
    'RPG Fantasy Game', 'Strategy Game', 'Street Fighter', 'Legend of Zelda',
    'Architectural', 'Disco', 'Dreamscape', 'Dystopian', 'Fairy Tale',
    'Gothic', 'Grunge', 'Horror', 'Minimalist', 'Monochrome', 'Nautical',
    'Space', 'Stained Glass', 'Techwear Fashion', 'Tribal', 'Zentangle',
    'Collage', 'Flat Papercut', 'Kirigami', 'Paper Mache', 'Paper Quilling',
    'Papercut Collage', 'Papercut Shadow Box', 'Stacked Papercut',
    'Thick Layered Papercut', 'Alien', 'Film Noir', 'HDR', 'Long Exposure',
    'Neon Noir', 'Silhouette', 'Tilt-Shift'
] 

async function generateImage(i) {
    try {
        const response = await axios.post(API_URL, {
            model: "fluently-xl",
            "height": 1024,
            "width": 1024,
            "steps": 30,
            "cfg_scale": 20.0,
            // "seed": 123456789,
            "style_preset": "HDR",
            "safe_mode": false,
            "return_binary": true,
            "hide_watermark": true,
            prompt: "Generate a paranomic scene in equirectangular format no stich lines"
            // prompt: "A richly detailed Persian carpet with intricate floral and lattice motifs, woven in crimson red and ivory color palette, featuring a central medallion layout and high-thread texture, symmetrical, 8K resolution, studio lighting"
        }, {
            headers: {
                "Authorization": `Bearer ${API_KEY}`,
                "Content-Type": "application/json",
            },
            responseType: 'arraybuffer' // To handle binary response
        });
        if (response.data) {  // Ensure image data exists
            // const base64Image = response.data; // Get base64 string
            // const imageBuffer = Buffer.from(base64Image, 'base64'); // Convert to buffer
            const filePath = `images/generated_image_${i}.png`; // Define file name
            fs.writeFileSync(filePath, response.data, "binary");

            // Write to file
            // fs.writeFileSync(filePath, imageBuffer);
            console.log(`Image saved as ${filePath}`);
        } else {
            console.error("No image data found in the response.");
        }
    } catch (error) {
        console.error("Error generating image:", error.response ? error.response.data : error.message);
    }
}


async function upscaleImage(imagePath) {
    try {
        const form = new FormData();
        form.append("image", fs.createReadStream(imagePath)); // Attach image file
        form.append("scale", "4");  // Or "4"

        const response = await axios.post("https://api.venice.ai/api/v1/image/upscale", form, {
            headers: {
                "Authorization": `Bearer ${API_KEY}`,
                ...form.getHeaders() // Let axios set the Content-Type with boundary
            },
            responseType: 'arraybuffer' // To handle binary response
        });

        // Save the upscaled image
        const outputPath = 'images/upscaled_image.png';
        fs.writeFileSync(outputPath, response.data, "binary");
        console.log(`Upscaled image saved as ${outputPath}`);
    } catch (error) {
        if (error.response) {
            console.error("Error upscaling image:", error.response.data);
            
        } else {
            console.error("Error upscaling image:", error.message);
        }
    }
}


// for (let i = 0; i < 10000; i++) {
//     // sleep(2000);
//     generateImage(i);
// }
generateImage(1);
// upscaleImage("images/generated_image_54.png");
