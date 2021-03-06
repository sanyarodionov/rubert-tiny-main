#!/bin/bash

pkill -f 'python -u train.py'
export NODE_RANK=0
export N_NODES=1

export CUDA_VISIBLE_DEVICES=0
export N_GPU_NODE=1
export WORLD_SIZE=1


python -m torch.distributed.launch \
    --nproc_per_node=$N_GPU_NODE \
    --nnodes=$N_NODES \
    --node_rank $NODE_RANK \
    train.py \
    --force \
    --dump_path distilrubert-tiny-match-contrastive-hyp-kl-mlm-neg_s-avg-all-dump \
    --tensorboard_logs_path tensorboard_logs_rubert_tiny_updated \
    --tensorboard_log_name distilrubert-tiny-match-contrastive-hyp-kl-mlm-neg_s-avg-all \
    --binarized_data_folder processed_binarized \
    --student_name distilrubert_tiny_cased_convers \
    --student_pretrained_weights distilrubert_tiny_weights.pth \
    --teacher_name ru_convers \
    --temperature 2 \
    --alpha_ce 2.0 --alpha_mlm 0.5 --alpha_contrastive 0.1 --projection_strategy average_by_layers \
    --project_to student \
    --align_logits match \
    --align_hiddens match --n_negative_samples 32 \
    --negative_sampling_strategy student \
    --student_token_counts student_counts.pickle \
    --n_epoch 64 --batch_size 4 --group_by_size \
    --gradient_accumulation_steps 128 \
    --learning_rate 5e-4 --valid_epochs_patience 3 --reduce_factor 5e-1 \
    --gpus $WORLD_SIZE \
    --seed 42 --log_interval 16 \
    --matching_ids matched_tokens.pickle \
    hyperbolic --init_c precompute_from_teacher \
    --n_samples_to_precompute_c 1000 \
    --n_components 1000 \
    --n_tries 3 \
    --use_hyperbolic_projections