

const variables = {
  get identity(): string {
    const figIdentity = Deno.env.get("FIG_IDENTITY")
    if (figIdentity) {
      return figIdentity
    } else {
      return 'unknown';
    }
  },
};

export default variables;
