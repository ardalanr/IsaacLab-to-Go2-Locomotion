import glob
import pickle as pkl
import lcm
import sys

from go2_gym_deploy.utils.deployment_runner import DeploymentRunner
from go2_gym_deploy.envs.lcm_agent import LCMAgent
from go2_gym_deploy.utils.cheetah_state_estimator import StateEstimator
from go2_gym_deploy.utils.command_profile import *
import numpy as np

import pathlib

# lcm多播通信的标准格式
lc = lcm.LCM("udpm://239.255.76.67:7667?ttl=255")

def load_and_run_policy(label, experiment_name, max_vel=1.0, max_yaw_vel=1.0):
    # load agent
    dirs = glob.glob(f"../../runs/{label}/*")
    logdir = sorted(dirs)[0]

# with open(logdir+"/parameters.pkl", 'rb') as file:
    with open(logdir+"/parameters_isaaclab.pkl", 'rb') as file:
        pkl_cfg = pkl.load(file)
        # print(pkl_cfg.keys())
        cfg = pkl_cfg["Cfg"]
        print(cfg["control"]["action_scale"])

    print('Config successfully loaded!')

    se = StateEstimator(lc)

    control_dt = 0.02
    command_profile = RCControllerProfile(dt=control_dt, state_estimator=se, x_scale=max_vel, y_scale=0.6, yaw_scale=max_yaw_vel)

    hardware_agent = LCMAgent(cfg, se, command_profile)
    se.spin()

    from go2_gym_deploy.envs.history_wrapper import HistoryWrapper
    hardware_agent = HistoryWrapper(hardware_agent)
    print('Agent successfully created!')

    policy = load_policy(logdir)
    print('Policy successfully loaded!')

    # load runner
    root = f"{pathlib.Path(__file__).parent.resolve()}/../../logs/"
    pathlib.Path(root).mkdir(parents=True, exist_ok=True)
    deployment_runner = DeploymentRunner(experiment_name=experiment_name, se=None,
                                         log_root=f"{root}/{experiment_name}")
    deployment_runner.add_control_agent(hardware_agent, "hardware_closed_loop")
    deployment_runner.add_policy(policy)
    deployment_runner.add_command_profile(command_profile)

    if len(sys.argv) >= 2:
        max_steps = int(sys.argv[1])
    else:
        max_steps = 10000000
    print(f'max steps {max_steps}')

    deployment_runner.run(max_steps=max_steps, logging=True)

def load_policy(logdir):
    # try ------------------
    body = torch.jit.load(logdir + '/checkpoints/policy_test_3.pt')
    # body = torch.jit.load(logdir + '/checkpoints/policy.pt')
    # body = torch.jit.load(logdir + '/checkpoints/body_latest.jit')

    import os
    # adaptation_module = torch.jit.load(logdir + '/checkpoints/adaptation_module_latest.jit').to('cpu')

    # print("--- Body Graph ---")
    # print(body._get_method("forward").graph)
    # print("------------------")

    def policy(obs, info):
        i = 0
        # import pdb; pdb.set_trace()
        # latent = adaptation_module.forward(obs["obs_history"].to('cpu'))
        # action = body.forward(torch.cat((obs["obs_history"].to('cpu'), latent), dim=-1))
        
        # input_tensor = torch.cat((obs["obs_history"].to('cpu'), latent), dim=-1)
        action = body.forward(obs["obs"].to('cpu'))
        info['latent'] = None
        # action = np.array([0, 0.3, -0.7, 0, 0.3, -0.7, 0, 0.3, -0.7, 0, 0.3, -0.7])[:np.newaxis]
        # action = np.array([0., 0., 0., 0.,
        #                    0.3, 0.3, 0.3, 0.3,
        #                    -0.7, -0.7, -0.7, -0.7,])
        # action = torch.from_numpy(action)
        # action = torch.zeros_like(action)
        # action[:, 0] = 2
        return action

    return policy


if __name__ == '__main__':
    # label = "gait-conditioned-agility/pretrain-v0/train"
    label = "gait-conditioned-agility/pretrain-go2/train"

    experiment_name = "example_experiment"

    # default:
    # max_vel=3.5, max_yaw_vel=5.0
    load_and_run_policy(label, experiment_name=experiment_name, max_vel=2.5, max_yaw_vel=5.0)
