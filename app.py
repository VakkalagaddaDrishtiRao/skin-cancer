import torch
import torch.nn as nn
import torchvision.transforms as transforms
from torchvision import models
import streamlit as st
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import cv2
import io

# ----------------------------
# Load Model
# ----------------------------
@st.cache_resource
def load_model(model_path="/Users/vakkalagaddadrishtirao/NIC/app/lib/skincancer/CNNClassifier.pth"):
    model = models.resnet18(pretrained=False)
    model.fc = nn.Linear(model.fc.in_features, 2)
    
    # Load the model state_dict with strict=False to handle missing/extra keys
    state_dict = torch.load(model_path, map_location=torch.device("cpu"))
    model.load_state_dict(state_dict, strict=False)  # Allow mismatched keys
    model.eval()
    return model

model = load_model()

# ----------------------------
# Grad-CAM Setup
# ----------------------------
class GradCAM:
    def __init__(self, model, target_layer):
        self.model = model
        self.gradients = None
        self.activations = None
        target_layer.register_forward_hook(self.forward_hook)
        target_layer.register_full_backward_hook(self.backward_hook)

    def forward_hook(self, module, input, output):
        self.activations = output

    def backward_hook(self, module, grad_input, grad_output):
        self.gradients = grad_output[0]

    def generate(self, input_tensor):
        output = self.model(input_tensor)
        pred_class = output.argmax().item()

        self.model.zero_grad()
        output[0, pred_class].backward()

        weights = self.gradients.mean(dim=[2, 3], keepdim=True)
        cam = (weights * self.activations).sum(dim=1, keepdim=True)
        cam = torch.relu(cam)
        cam = cam.squeeze().detach().numpy()
        cam = cv2.resize(cam, (128, 128))
        cam = (cam - cam.min()) / (cam.max() - cam.min() + 1e-8)
        return cam, pred_class

# ----------------------------
# Image Preprocessing
# ----------------------------
transform = transforms.Compose([
    transforms.Resize((128, 128)),
    transforms.ToTensor(),
    transforms.Normalize([0.5]*3, [0.5]*3)
])

# ----------------------------
# UI Layout
# ----------------------------
st.title("🔬 Skin Cancer Detection")
st.markdown("Upload a skin lesion image to predict if it's **Benign** or **Malignant**.")

uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "jpeg", "png"])
if uploaded_file:
    # Show image
    image = Image.open(uploaded_file).convert("RGB")
    st.image(image, caption="Uploaded Image",  use_container_width=True)

    with st.spinner("Analyzing Image..."):
        input_tensor = transform(image).unsqueeze(0)

        # Prediction
        outputs = model(input_tensor)
        _, predicted = torch.max(outputs, 1)
        prediction = "Malignant" if predicted.item() == 0 else "Benign"
        confidence = torch.softmax(outputs, dim=1)[0][predicted.item()].item() * 100

        st.success(f"**Prediction:** {prediction} ")

        # Grad-CAM
        grad_cam = GradCAM(model, model.layer4[1].conv2)  # Ensure this layer is relevant for Grad-CAM
        heatmap, _ = grad_cam.generate(input_tensor)

        # Overlay Heatmap
        img_array = np.array(image.resize((128, 128)))
        heatmap_color = cv2.applyColorMap(np.uint8(255 * heatmap), cv2.COLORMAP_JET)
        overlayed = cv2.addWeighted(img_array, 0.6, heatmap_color, 0.4, 0)

        st.markdown("### Grad-CAM Heatmap")
        st.image(overlayed,  use_container_width=True, caption="Model Focus Area")
