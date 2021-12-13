local train_data = "/content/HAREM/data/harem_train_total_conll2003.txt";
local dev_data = "/content/HAREM/data/harem_test_total_conll2003.txt";

local transformer_model = "neuralmind/bert-base-portuguese-cased";
local transformer_hidden_dim = 768;
local epochs = 20;
local batch_size = 16;
local max_length = 512;

{
    "dataset_reader": {
        "type": "conll2003",
        "coding_scheme": "IOB1",
        "token_indexers": {
          "tokens": {
            "type": "pretrained_transformer_mismatched",
            "model_name": transformer_model,
            "max_length": max_length
          },
        },
    },
    "train_data_path": train_data,
    "validation_data_path": dev_data,
    "data_loader": {
        "batch_sampler": {
            "type": "bucket",
            "batch_size": batch_size
        }
    },
    "model": {
        "type": "simple_tagger",
        "encoder": {
            "type": "pass_through",
            "input_dim": transformer_hidden_dim,
        },
        "label_encoding": "IOB1",
        "text_field_embedder": {
          "token_embedders": {
            "tokens": {
                "type": "pretrained_transformer_mismatched",
                "model_name": transformer_model,
                "max_length": max_length
            }
          }
        },
        "verbose_metrics": false
    },
    "trainer": {
        "optimizer": {
          "type": "huggingface_adamw",
          "weight_decay": 0.01,
          "parameter_groups": [[["bias", "LayerNorm\\.weight", "layer_norm\\.weight"], {"weight_decay": 0}]],
          "lr": 1e-5,
          "eps": 1e-8,
          "correct_bias": true,
        },
        "learning_rate_scheduler": {
          "type": "linear_with_warmup",
          "warmup_steps": 100,
        },
        // "grad_norm": 1.0,
        "num_epochs": epochs,
        "validation_metric": "+f1-measure-overall",
        "patience": 3
    }
}