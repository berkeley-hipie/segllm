#!/bin/bash

CHECKPOINT=Marlo-Z/SegLLM/mr_refcoco_checkpoint
SEG_CONFIG_FILE=refcoco_val.yaml

# -------------------------- MR-RefCOCO -----------------------

RESULTS_PATH=./val_results/mr_refcoco_eval_results.txt
CONV_DIR=all_data_mix_val
DATASETS=("refcoco" "refcoco+" "refcocog")
for dataset in "${DATASETS[@]}"
do
    VAL_DATA=mr_${dataset}_val.json
    deepspeed \
        --include "localhost:${LOCAL_HOST}" \
        --master_port 12340 \
        llava/train/train_mem.py \
        --deepspeed ./scripts/deepspeed_configs/zero2.json \
        --model_name_or_path liuhaotian/llava-v1.5-7b \
        --load $CKPT \
        --image_folder ./images_folder \
        --annotation_folder ./annotations_folder \
        --conversation_folder ./conversations_folder/${CONV_DIR} \
        --segmentation_config ./scripts/annotation_configs/val/${SEG_CONFIG_FILE} \
        --val_dataset $VAL_DATA \
        --val_results_save_file $RESULTS_PATH \
        --lora_enable False \
        --split_loading False \
        --version plain \
        --mm_use_seg True \
        --segmentator hipie \
        --vision_tower openai/clip-vit-large-patch14 \
        --mm_projector_type mlp2x_gelu \
        --tune_mm_mlp_adapter False \
        --mm_vision_select_layer -2 \
        --mm_use_im_start_end False \
        --mm_vision_select_feature patch \
        --mm_use_im_patch_token False \
        --bf16 True \
        --fp16 False \
        --tf32 False \
        --mm_use_gen True \
        --num_train_epochs 2 \
        --per_device_train_batch_size 4 \
        --gradient_accumulation_steps 1 \
        --evaluation_strategy "steps" \
        --save_strategy "steps" \
        --save_steps 500 \
        --save_total_limit 2 \
        --learning_rate 2e-5 \
        --weight_decay 0. \
        --eval_steps 1000 \
        --warmup_ratio 0.03 \
        --lr_scheduler_type "cosine" \
        --logging_steps 1 \
        --model_max_length 2048 \
        --gradient_checkpointing True \
        --dataloader_num_workers 4 \
        --lazy_preprocess True \
        --report_to wandb ${@:1} \
        --output_text \
        --do_eval \
        --eval_only \
        --output_dir ./val_output \
        --eval_use_gt_mask_encode True \
        --per_device_eval_batch_size 1 \
        --ar_eval
done

# -------------------------- Refer Seg -------------------------

CONV_DIR=refcoco_single_round_val
RESULTS_PATH=./val_results/refcoco_eval_results.txt

# Refcoco single (val, testA, testB)
SPLITS=("val" "testA" "testB")
for split in "${SPLITS[@]}"
do
    VAL_DATA=refcoco_${split}.json
    deepspeed \
        --include "localhost:${LOCAL_HOST}" \
        --master_port 12340 \
        llava/train/train_mem.py \
        --deepspeed ./scripts/deepspeed_configs/zero2.json \
        --model_name_or_path liuhaotian/llava-v1.5-7b \
        --load $CKPT \
        --image_folder ./images_folder \
        --annotation_folder ./annotations_folder \
        --conversation_folder ./conversations_folder/${CONV_DIR} \
        --segmentation_config ./scripts/annotation_configs/val/${SEG_CONFIG_FILE} \
        --val_dataset $VAL_DATA \
        --val_results_save_file $RESULTS_PATH \
        --lora_enable False \
        --split_loading False \
        --version plain \
        --mm_use_seg True \
        --segmentator hipie \
        --vision_tower openai/clip-vit-large-patch14 \
        --mm_projector_type mlp2x_gelu \
        --tune_mm_mlp_adapter False \
        --mm_vision_select_layer -2 \
        --mm_use_im_start_end False \
        --mm_vision_select_feature patch \
        --mm_use_im_patch_token False \
        --bf16 True \
        --fp16 False \
        --tf32 False \
        --mm_use_gen True \
        --num_train_epochs 2 \
        --per_device_train_batch_size 4 \
        --gradient_accumulation_steps 1 \
        --evaluation_strategy "steps" \
        --save_strategy "steps" \
        --save_steps 500 \
        --save_total_limit 2 \
        --learning_rate 2e-5 \
        --weight_decay 0. \
        --eval_steps 1000 \
        --warmup_ratio 0.03 \
        --lr_scheduler_type "cosine" \
        --logging_steps 1 \
        --model_max_length 2048 \
        --gradient_checkpointing True \
        --dataloader_num_workers 4 \
        --lazy_preprocess True \
        --report_to wandb ${@:1} \
        --output_text \
        --do_eval \
        --eval_only \
        --output_dir ./val_output \
        --eval_use_gt_mask_encode True \
        --per_device_eval_batch_size 1
done

# Refcoco+ single (val, testA, testB)
SPLITS=("val" "testA" "testB")
for split in "${SPLITS[@]}"
do
    VAL_DATA=refcoco+_${split}.json
    deepspeed \
        --include "localhost:${LOCAL_HOST}" \
        --master_port 12340 \
        llava/train/train_mem.py \
        --deepspeed ./scripts/deepspeed_configs/zero2.json \
        --model_name_or_path liuhaotian/llava-v1.5-7b \
        --load $CKPT \
        --image_folder ./images_folder \
        --annotation_folder ./annotations_folder \
        --conversation_folder ./conversations_folder/${CONV_DIR} \
        --segmentation_config ./scripts/annotation_configs/val/${SEG_CONFIG_FILE} \
        --val_dataset $VAL_DATA \
        --val_results_save_file $RESULTS_PATH \
        --lora_enable False \
        --split_loading False \
        --version plain \
        --mm_use_seg True \
        --segmentator hipie \
        --vision_tower openai/clip-vit-large-patch14 \
        --mm_projector_type mlp2x_gelu \
        --tune_mm_mlp_adapter False \
        --mm_vision_select_layer -2 \
        --mm_use_im_start_end False \
        --mm_vision_select_feature patch \
        --mm_use_im_patch_token False \
        --bf16 True \
        --fp16 False \
        --tf32 False \
        --mm_use_gen True \
        --num_train_epochs 2 \
        --per_device_train_batch_size 4 \
        --gradient_accumulation_steps 1 \
        --evaluation_strategy "steps" \
        --save_strategy "steps" \
        --save_steps 500 \
        --save_total_limit 2 \
        --learning_rate 2e-5 \
        --weight_decay 0. \
        --eval_steps 1000 \
        --warmup_ratio 0.03 \
        --lr_scheduler_type "cosine" \
        --logging_steps 1 \
        --model_max_length 2048 \
        --gradient_checkpointing True \
        --dataloader_num_workers 4 \
        --lazy_preprocess True \
        --report_to wandb ${@:1} \
        --output_text \
        --do_eval \
        --eval_only \
        --output_dir ./val_output \
        --eval_use_gt_mask_encode True \
        --per_device_eval_batch_size 1
done

# Refcocog single (val, test)
SPLITS=("val" "test")
for split in "${SPLITS[@]}"
do
    VAL_DATA=refcocog_${split}.json
    deepspeed \
        --include "localhost:${LOCAL_HOST}" \
        --master_port 12340 \
        llava/train/train_mem.py \
        --deepspeed ./scripts/deepspeed_configs/zero2.json \
        --model_name_or_path liuhaotian/llava-v1.5-7b \
        --load $CKPT \
        --image_folder ./images_folder \
        --annotation_folder ./annotations_folder \
        --conversation_folder ./conversations_folder/${CONV_DIR} \
        --segmentation_config ./scripts/annotation_configs/val/${SEG_CONFIG_FILE} \
        --val_dataset $VAL_DATA \
        --val_results_save_file $RESULTS_PATH \
        --lora_enable False \
        --split_loading False \
        --version plain \
        --mm_use_seg True \
        --segmentator hipie \
        --vision_tower openai/clip-vit-large-patch14 \
        --mm_projector_type mlp2x_gelu \
        --tune_mm_mlp_adapter False \
        --mm_vision_select_layer -2 \
        --mm_use_im_start_end False \
        --mm_vision_select_feature patch \
        --mm_use_im_patch_token False \
        --bf16 True \
        --fp16 False \
        --tf32 False \
        --mm_use_gen True \
        --num_train_epochs 2 \
        --per_device_train_batch_size 4 \
        --gradient_accumulation_steps 1 \
        --evaluation_strategy "steps" \
        --save_strategy "steps" \
        --save_steps 500 \
        --save_total_limit 2 \
        --learning_rate 2e-5 \
        --weight_decay 0. \
        --eval_steps 1000 \
        --warmup_ratio 0.03 \
        --lr_scheduler_type "cosine" \
        --logging_steps 1 \
        --model_max_length 2048 \
        --gradient_checkpointing True \
        --dataloader_num_workers 4 \
        --lazy_preprocess True \
        --report_to wandb ${@:1} \
        --output_text \
        --do_eval \
        --eval_only \
        --output_dir ./val_output \
        --eval_use_gt_mask_encode True \
        --per_device_eval_batch_size 1
done

# ------------------------------ Templates ---------------------------------

CONV_DIR=refcoco_single_round_val
RESULTS_PATH=./val_results/templates_refcoco_eval_results.txt

DATASETS=("refcoco" "refcoco+" "refcocog")
TEMPLATES=("lisa" "sesame")
for dataset in "${DATASETS[@]}"
do
    for template in "${TEMPLATES[@]}"
    do   
        VAL_DATA=${dataset}_val_${template}_templates.json
        deepspeed \
            --include "localhost:${LOCAL_HOST}" \
            --master_port 12340 \
            llava/train/train_mem.py \
            --deepspeed ./scripts/deepspeed_configs/zero2.json \
            --model_name_or_path liuhaotian/llava-v1.5-7b \
            --load $CKPT \
            --image_folder ./images_folder \
            --annotation_folder ./annotations_folder \
            --conversation_folder ./conversations_folder/${CONV_DIR} \
            --segmentation_config ./scripts/annotation_configs/val/${SEG_CONFIG_FILE} \
            --val_dataset $VAL_DATA \
            --val_results_save_file $RESULTS_PATH \
            --lora_enable False \
            --split_loading False \
            --version plain \
            --mm_use_seg True \
            --segmentator hipie \
            --vision_tower openai/clip-vit-large-patch14 \
            --mm_projector_type mlp2x_gelu \
            --tune_mm_mlp_adapter False \
            --mm_vision_select_layer -2 \
            --mm_use_im_start_end False \
            --mm_vision_select_feature patch \
            --mm_use_im_patch_token False \
            --bf16 True \
            --fp16 False \
            --tf32 False \
            --mm_use_gen True \
            --num_train_epochs 2 \
            --per_device_train_batch_size 4 \
            --gradient_accumulation_steps 1 \
            --evaluation_strategy "steps" \
            --save_strategy "steps" \
            --save_steps 500 \
            --save_total_limit 2 \
            --learning_rate 2e-5 \
            --weight_decay 0. \
            --eval_steps 1000 \
            --warmup_ratio 0.03 \
            --lr_scheduler_type "cosine" \
            --logging_steps 1 \
            --model_max_length 2048 \
            --gradient_checkpointing True \
            --dataloader_num_workers 4 \
            --lazy_preprocess True \
            --report_to wandb ${@:1} \
            --output_text \
            --do_eval \
            --eval_only \
            --output_dir ./val_output \
            --eval_use_gt_mask_encode True \
            --per_device_eval_batch_size 1
    done
done