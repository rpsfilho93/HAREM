// Configuration for a named entity recognization model based on:
//   Peters, Matthew E. et al. “Deep contextualized word representations.” NAACL-HLT (2018).

local train_data = "/content/HAREM/data/harem_train_total_conll2003.txt";
local dev_data = "/content/HAREM/data/harem_test_total_conll2003.txt";

{
  "dataset_reader": {
    "type": "conll2003",
    "tag_label": "ner",
    "coding_scheme": "BIOUL",
    "token_indexers": {
      "tokens": {
        "type": "single_id",
        "lowercase_tokens": true
      },
      "token_characters": {
        "type": "characters",
        "min_padding_length": 3
      }
    }
  },
  "train_data_path": train_data,
  "validation_data_path": dev_data,
  "model": {
    "type": "crf_tagger",
    "label_encoding": "BIOUL",
    "constrain_crf_decoding": true,
    "calculate_span_f1": true,
    "dropout": 0.5,
    "include_start_end_transitions": false,
    "text_field_embedder": {
      "token_embedders": {
        "tokens": {
            "type": "embedding",
            "embedding_dim": 1000,
            "pretrained_file": "http://143.107.183.175:22980/download.php?file=embeddings/glove/glove_s1000.zip",
            "trainable": true
        },
        "token_characters": {
            "type": "character_encoding",
            "embedding": {
                "embedding_dim": 16
            },
            "encoder": {
                "type": "cnn",
                "embedding_dim": 16,
                "num_filters": 128,
                "ngram_filter_sizes": [3],
                "conv_layer_activation": "relu"
            }
          }
       },
    },
    "encoder": {
        "type": "lstm",
        "input_size": 1000 + 128,
        "hidden_size": 200,
        "num_layers": 2,
        "dropout": 0.5,
        "bidirectional": true
    },
  },
  "data_loader": {
    "batch_size": 64
  },
  "trainer": {
    "optimizer": {
        "type": "adam",
        "lr": 0.001
    },
    "checkpointer": {
        "keep_most_recent_by_count": 3,
    },
    "validation_metric": "+f1-measure-overall",
    "num_epochs": 75,
    "grad_norm": 5.0,
    "patience": 25,
  }
}