if 'condition' not in globals():
    from mage_ai.data_preparation.decorators import condition


@condition
def evaluate_condition(*args, **kwargs) -> bool:
    # Shuts off the AWS-related branch if local,
    run_branch = dbt_mode = kwargs.get("dbt_mode", "local").lower() == "aws"
    print("AWS-branch is executed: ", run_branch)
    return run_branch
