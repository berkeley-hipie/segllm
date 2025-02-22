import torch
import torch.nn as nn

from transformers import CLIPVisionModelWithProjection, CLIPImageProcessor, CLIPVisionConfig


class CLIPVisionTower(nn.Module):
    def __init__(self, vision_tower, args, delay_load=False):
        super().__init__()

        self.is_loaded = False

        self.vision_tower_name = vision_tower
        self.select_layer = args.mm_vision_select_layer
        self.select_feature = getattr(args, 'mm_vision_select_feature', 'projection')

        if not delay_load:
            self.load_model()
        else:
            self.cfg_only = CLIPVisionConfig.from_pretrained(self.vision_tower_name)

    def load_model(self):
        self.image_processor = CLIPImageProcessor.from_pretrained(self.vision_tower_name)
        self.vision_tower = CLIPVisionModelWithProjection.from_pretrained(self.vision_tower_name)
        self.vision_tower.requires_grad_(False)

        self.is_loaded = True

    def feature_select(self, image_forward_outs,select_feature=None):
        image_features = image_forward_outs.hidden_states[self.select_layer]
        if select_feature is None:
            select_feature = self.select_feature
        if select_feature == 'patch':
            image_features = image_features[:, 1:]
        elif select_feature == 'cls_patch':
            image_features = image_features
        elif select_feature == 'cls':
            image_features = image_features[:, :1]
        elif select_feature == 'projection':
            image_features = image_forward_outs.image_embeds.unsqueeze(1)
        else:
            raise ValueError(f'Unexpected select feature: {self.select_feature}')
        return image_features

    @torch.no_grad()
    def forward(self, images,select_feature=None):
        if type(images) is list:
            image_features = []
            for image in images:
                image_forward_out = self.vision_tower(image.to(device=self.device, dtype=self.dtype).unsqueeze(0), output_hidden_states=True)
                image_feature = self.feature_select(image_forward_out,select_feature).to(image.dtype)
                image_features.append(image_feature)
        elif isinstance(images,torch.Tensor):
            image_forward_outs = self.vision_tower(images.to(device=self.device), output_hidden_states=True)
            image_features = self.feature_select(image_forward_outs,select_feature).to(images.dtype)
        else:
            return torch.zeros(images['image']['pixel_values'].shape[0],1,1024).to(images['image']['pixel_values'].dtype).to(device=self.device)
            image_forward_outs = self.vision_tower(images['image']['pixel_values'].to(device=self.device), output_hidden_states=True)
            image_features = self.feature_select(image_forward_outs).to(images['image']['pixel_values'].dtype)

        return image_features


    @property
    def dummy_feature(self):
        return torch.zeros(1, self.hidden_size, device=self.device, dtype=self.dtype)

    @property
    def dtype(self):
        return self.vision_tower.dtype

    @property
    def device(self):
        return self.vision_tower.device

    @property
    def config(self):
        if self.is_loaded:
            return self.vision_tower.config
        else:
            return self.cfg_only

    @property
    def hidden_size(self):
        return self.config.projection_dim if self.select_feature == 'projection' else self.config.hidden_size

    @property
    def num_patches(self):
        return (self.config.image_size // self.config.patch_size) ** 2
