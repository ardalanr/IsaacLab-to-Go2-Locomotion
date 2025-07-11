import torch
model = torch.jit.load("policy.pt")
model.save("policy_broken.jit")
