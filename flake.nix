{
  description = "The terminal for ExpidusOS";

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
  };

  outputs = { self, expidus-sdk }: expidus-sdk.libExpidus.mkFlake { inherit self; name = "expidus-terminal"; };
}
