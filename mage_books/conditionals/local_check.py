if 'condition' not in globals():
    from mage_ai.data_preparation.decorators import condition


@condition
def evaluate_condition(*args, **kwargs) -> bool:
    # Shuts off the local-related branch if local,
    run_branch = kwargs.get("dbt_mode", "None").lower() == "local"
    print("Local-branch is executed: ", run_branch)
    return run_branch
