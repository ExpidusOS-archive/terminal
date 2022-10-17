{
  description = "The terminal for ExpidusOS";

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
  };

  outputs = { self, expidus-sdk }: expidus-sdk.lib.mkFlake { inherit self; name = "expidus-terminal"; };
}
